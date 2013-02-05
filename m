From: Ben Pfaff <blp@cs.stanford.edu>
Subject: Re: No sysfs directory for openvswitch module when built-in
Date: Tue, 5 Feb 2013 11:15:54 -0800
Message-ID: <20130205191554.GA7573@blp.benpfaff.org>
References: <CAM_iQpVgEchb8UsxUP=w6OMbYx=zuP2yv=QwFhe8rPCbNBreVg@mail.gmail.com>
 <20130204081920.00e9f22e@nehalam.linuxnetplumber.net>
 <87lib3gunm.fsf@blp.benpfaff.org>
 <CAM_iQpXSv7ddFtF53JGu=QdaNgY7c4O9Wuq4PmVRczTBiE_rSg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Jesse Gross <jesse@nicira.com>,
	"David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:46694 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754890Ab3BETQA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 14:16:00 -0500
Content-Disposition: inline
In-Reply-To: <CAM_iQpXSv7ddFtF53JGu=QdaNgY7c4O9Wuq4PmVRczTBiE_rSg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 05, 2013 at 06:49:45PM +0800, Cong Wang wrote:
> On Tue, Feb 5, 2013 at 2:08 PM, Ben Pfaff <blp@cs.stanford.edu> wrote:
> > Stephen Hemminger <stephen@networkplumber.org> writes:
> >
> >> On Tue, 29 Jan 2013 22:15:18 +0800
> >> Cong Wang <xiyou.wangcong@gmail.com> wrote:
> >>
> >>> Hello, Rusty, Jesse,
> >>>
> >>> I met an interesting problem when I compile openvswitch module as a
> >>> built-in (actually I compile ALL kernel modules as built-in), there is
> >>> no /sys/module/openvswitch/ directory created by the kernel in this
> >>> case.
> >>>
> >>> What's worse, the user-space init script thinks openvswitch module is
> >>> not loaded by checking the exist of this directory, therefore refuses
> >>> to start.
> >>
> >> Shouldn't the OVS init script be testing for some other API.
> >
> > I agree that's a bug in the OVS init script.  I will fix it.
> 
> Thanks for taking care of it, Ben!

I posted a patch to ovs-dev for review:
        http://openvswitch.org/pipermail/dev/2013-February/025128.html
