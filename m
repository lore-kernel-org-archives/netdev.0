From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH v8 00/16] Provide a zero-copy method on KVM
 virtio-net.
Date: Sun, 1 Aug 2010 11:31:13 +0300
Message-ID: <20100801083113.GB16158@redhat.com>
References: <1280402088-5849-1-git-send-email-xiaohui.xin@intel.com>
 <1280442682.9058.15.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, davem@davemloft.net,
	herbert@gondor.hengli.com.au, jdike@linux.intel.com
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9380 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755266Ab0HAIgx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Aug 2010 04:36:53 -0400
Content-Disposition: inline
In-Reply-To: <1280442682.9058.15.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 29, 2010 at 03:31:22PM -0700, Shirley Ma wrote:
> I did some vhost performance measurement over 10Gb ixgbe, and found that
> in order to get consistent BW results, netperf/netserver, qemu, vhost
> threads smp affinities are required.

Could you provide an example of a good setup?
Specifically, is it a good idea for the vhost thread
to inherit CPU affinities from qemu?

> Looking forward to these results for small message size comparison.

I think we should explore the idea for the driver to fall back on data copy
for small message sizes.
The benefit of zero copy would then be CPU utilization on large messages.

> For
> large message size 10Gb ixgbe BW already reached by doing vhost smp
> affinity w/i offloading support, we will see how much CPU utilization it
> can be reduced. 
> 
> Please provide latency results as well. I did some experimental on
> macvtap zero copy sendmsg, what I have found that get_user_pages latency
> pretty high.
> 
> Thanks
> Shirley
> 
> 
> 
