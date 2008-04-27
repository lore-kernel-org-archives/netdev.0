From: "M. Istehbab" <hariskhan@gmail.com>
Subject: Re: TCP connection failure in kernel 2.6.25
Date: Sun, 27 Apr 2008 11:02:51 +0500
Message-ID: <c1410bfe0804262302p3f283f9k97a04ff11dd2779e@mail.gmail.com>
References: <c1410bfe0804260217t33139fd2v324af1a149843989@mail.gmail.com>
	 <1209205136.2929.6.camel@localhost.localdomain>
	 <c1410bfe0804260516k1149fadaoc06f02b94dcd12e9@mail.gmail.com>
	 <1209241624.2929.17.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, "H. Willstrand" <h.willstrand@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.175]:60774 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751776AbYD0GCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 02:02:52 -0400
Received: by wf-out-1314.google.com with SMTP id 28so3501710wff.4
        for <netdev@vger.kernel.org>; Sat, 26 Apr 2008 23:02:52 -0700 (PDT)
In-Reply-To: <1209241624.2929.17.camel@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 27, 2008 at 1:27 AM, H. Willstrand <h.willstrand@gmail.com> wrote:
> On Sat, 2008-04-26 at 17:16 +0500, M. Istehbab wrote:
> > Yes, after a while (it can be a few seconds, minutes, or 1+ hour) the
> > proxy server starts accepting connections again. I don't need to
> > reboot the box when this happens.
> >
> > This happens randomely to anyone behind it. Then, after a while, it
> > starts working again by itself.
> >
> Well, there are too many possibilities for failures... the Linux
> distribution (RHEL 3 workstation) was built for 2.4.21 (around year
> 2003) and you try 2.6.x
>
> Maybe you should stick to one of the later 2.4.x kernels or even better
> upgrade the Linux distribution.
>
> Cheers,
> H. Willstrand


I didn't have problems with rhel ws3 or with the kernel it came with.
I removed it in favour of debian a long time back, when debian/etch r0
was released.

I have been running debian etch r2 (4.0 r2) ever since, which comes
with kernel (2.6.18-5-686). As you might notice from the mentioned
kernel versions, I tried upgrading to kernels from lenny/debian and
sid/debian hoping to find a solution. I tried from 2.3.13 - 2.6.25
from both debian packages and vanilla sources (as they are called),
but the problem persists. It started and is continuing on debian.

I have 2 ISPs hooked into this box. One is CIR, the other is ADSL. The
ADSL runs over pppoe. I don't know if the 2.4.x kernels support pppoe.
The 2.6.x kernels do. I need to run 2 ISPs on this box seemlessly.

The last rhel version I used was using kernel 2.6.9. I'm going to grab
that and see if that helps.

I need pppoe, iptables, vpn, scsi with raid support, smp, and a around
8000 file descriptors to run stable on this box.

M. Istehbab
