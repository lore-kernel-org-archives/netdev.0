From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv2 0/2] vhost: a kernel-level virtio server
Date: Wed, 12 Aug 2009 16:04:34 +0300
Message-ID: <20090812130433.GB29200@redhat.com>
References: <20090811212743.GA26309@redhat.com> <4A820391.1090404@gmail.com> <20090812071636.GA26847@redhat.com> <4A82ADD5.6040909@gmail.com> <20090812120541.GA29158@redhat.com> <4A82B87B.4010208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu,
	linux-mm@kvack.org,
	"akpm@linux-foundation.org >> Andrew Morton"
	<akpm@linux-foundation.org>, hpa@zytor.com,
	Patrick Mullaney <pmullaney@novell.com>
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:55151 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752213AbZHLNHL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 09:07:11 -0400
Content-Disposition: inline
In-Reply-To: <4A82B87B.4010208@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 12, 2009 at 08:41:31AM -0400, Gregory Haskins wrote:
> Michael S. Tsirkin wrote:
> > On Wed, Aug 12, 2009 at 07:56:05AM -0400, Gregory Haskins wrote:
> >> Michael S. Tsirkin wrote:
> 
> <snip>
> 
> >>>
> >>> 1. use a dedicated network interface with SRIOV, program mac to match
> >>>    that of guest (for testing, you can set promisc mode, but that is
> >>>    bad for performance)
> >>
> >> Are you saying SRIOV is a requirement, and I can either program the
> >> SRIOV adapter with a mac or use promis?  Or are you saying I can use
> >> SRIOV+programmed mac OR a regular nic + promisc (with a perf penalty).
> > 
> > SRIOV is not a requirement. And you can also use a dedicated
> > nic+programmed mac if you are so inclined.
> 
> Makes sense.  Got it.
> 
> I was going to add guest-to-guest to the test matrix, but I assume that
> is not supported with vhost unless you have something like a VEPA
> enabled bridge?
> 
> <snip>

Presumably you mean on the same host?  There were also some patches to
enable local guest to guest for macvlan, that would be a nice
software-only solution.  For back to back, I just tried over veth, seems
to work fine.

> >>> 3. add vhost=ethX
> >> You mean via "ip link" I assume?
> > 
> > No, that's a new flag for virtio in qemu:
> > 
> > -net nic,model=virtio,vhost=veth0
> 
> Ah, ok.  Even better.
> 
> Thanks!
> -Greg
> 


