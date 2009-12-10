From: Ingo Molnar <mingo@elte.hu>
Subject: Re: nfs broken in net-next? -- now in mainline
Date: Thu, 10 Dec 2009 08:33:25 +0100
Message-ID: <20091210073325.GH16874@elte.hu>
References: <86802c440912091234t74fd2311t33c85379c06dd55c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Suresh Jayaraman <sjayaraman@suse.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:58098 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760508AbZLJHd1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Dec 2009 02:33:27 -0500
Content-Disposition: inline
In-Reply-To: <86802c440912091234t74fd2311t33c85379c06dd55c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Yinghai Lu <yhlu.kernel@gmail.com> wrote:

> On Thu, Oct 29, 2009 at 2:03 AM, Yinghai Lu <yhlu.kernel@gmail.com> wrote:
> > On Thu, Oct 29, 2009 at 12:23 AM, Suresh Jayaraman <sjayaraman@suse.de> wrote:
> >> On 10/29/2009 01:43 AM, Yinghai Lu wrote:
> >>> pk12-3214-189-102:~ # mount -t nfs 10.6.75.100:/data/shared/pxeboot /x
> >>> mount.nfs: rpc.statd is not running but is required for remote locking.
> >>> mount.nfs: Either use '-o nolock' to keep locks local, or start statd.
> >>
> >> rpc.statd on client should have be started by mount.nfs when a nfs
> >> filesystem is mounted. Is this not happening for some reason or do you
> >> see any errors in syslog?
> >>
> >>>
> >>> using opensuse11.1
> >>>
> >>
> >> Are you using 11.1 betas? I know of a problem where non-root user mounts
> >> fail to start rpc.statd in betas that got fixed later:
> >>
> >> http://marc.info/?l=linux-nfs&m=122748525624094&w=2
> >>
> >> Is the problem seen only recently (after updating to net-next)?
> >>
> >
> > only happen with net-next.
> >
> > linus tree and tip tree are ok.
> >
> 
> Finally it reached linus tree and tip.

In the quoted text above it's being disputed that it's a kernel 
regression so i guess your best option is to bisect it (if you can).

	Ingo
