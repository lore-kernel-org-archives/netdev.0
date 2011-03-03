From: Andrew Theurer <habanero@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/3] [RFC] Implement multiqueue (RX & TX) virtio-net
Date: Thu, 03 Mar 2011 13:01:24 -0600
Message-ID: <1299178884.13202.50.camel@localhost.localdomain>
References: <20110228063427.24908.63561.sendpatchset@krkumar2.in.ibm.com>
Reply-To: habanero@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, davem@davemloft.net, mst@redhat.com,
	eric.dumazet@gmail.com, arnd@arndb.de, netdev@vger.kernel.org,
	horms@verge.net.au, avi@redhat.com, anthony@codemonkey.ws,
	kvm@vger.kernel.org
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:45252 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752418Ab1CCTBb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 14:01:31 -0500
In-Reply-To: <20110228063427.24908.63561.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-02-28 at 12:04 +0530, Krishna Kumar wrote:
> This patch series is a continuation of an earlier one that
> implemented guest MQ TX functionality.  This new patchset
> implements both RX and TX MQ.  Qemu changes are not being
> included at this time solely to aid in easier review.
> Compatibility testing with old/new combinations of qemu/guest
> and vhost was done without any issues.
> 
> Some early TCP/UDP test results are at the bottom of this
> post, I plan to submit more test results in the coming days.
> 
> Please review and provide feedback on what can improve.
> 
> Thanks!
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
> 
> 
> Test configuration:
>           Host:  8 Intel Xeon, 8 GB memory
>           Guest: 4 cpus, 2 GB memory
> 
> Each test case runs for 60 secs, results below are average over
> two runs.  Bandwidth numbers are in gbps.  I have used default
> netperf, and no testing/system tuning other than taskset each
> vhost to 0xf (cpus 0-3).  Comparison is testing original kernel
> vs new kernel with #txqs=8 ("#" refers to number of netperf
> sessions).

> 
> _______________________________________________________________________
>                 TCP: Guest -> Local Host (TCP_STREAM)
>                  TCP: Local Host -> Guest (TCP_MAERTS)
>             UDP: Local Host -> Guest (UDP_STREAM)


Any reason why the tests don't include a guest-to-guest on same host, or
on different hosts?  Seems like those would be a lot more common that
guest-to/from-localhost.

Thanks,

-Andrew


