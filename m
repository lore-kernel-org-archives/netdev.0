From: Chris Adams <cmadams@hiwaay.net>
Subject: Re: r8169 performance?
Date: Tue, 6 Dec 2011 22:19:19 -0600
Message-ID: <20111207041919.GE3937@hiwaay.net>
References: <20111204211007.GA32098@hiwaay.net> <20111204234004.GA32515@electric-eye.fr.zoreil.com> <20111205004650.GA5948@hiwaay.net> <20111205064403.GA3426@electric-eye.fr.zoreil.com> <20111205145454.GA26078@hiwaay.net> <20111206082247.GA29089@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hayeswang <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fly.hiwaay.net ([216.180.54.1]:42256 "EHLO fly.hiwaay.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753289Ab1LGETZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 23:19:25 -0500
Content-Disposition: inline
In-Reply-To: <20111206082247.GA29089@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Once upon a time, Francois Romieu <romieu@fr.zoreil.com> said:
> It will disappear once http://marc.info/?l=linux-netdev&m=132306718323579
> is applied. You may apply http://marc.info/?l=linux-netdev&m=132306715823570
> too but I doubt it will make much difference for you.

I'll give it a try to double-check (it'll probably be a few days before
I can get to it).

> > Also, they load different firmware (so I guess my problem could be firmware
> > related, which I guess only RealTek could find/fix).
> >
> > I guess my question is this: is there a chance this can be solved with
> > driver changes, or should I just accept that the on-board NIC has poor
> > performance and install an add-in NIC?
> 
> (I understand that the systems (CPU, bus...) are not necessary the same.)
> 
> Did you check if Tx checksumming is enabled ?
> 
> It could make a noticeable difference.

That is off on both of my r8169 systems.  Enabling it on the "good"
system killed networking (even my existing SSH session was hung) until I
re-disabled it.  Enabling it on the "problem" system didn't appear to
make any significant difference.

The otherwise "good" system is running an older kernel (Fedora 14,
2.6.35.14); maybe some changes have been made so that "tx on" works on a
newer driver?  Or maybe the slightly different chip revision is the
difference.
-- 
Chris Adams <cmadams@hiwaay.net>
Systems and Network Administrator - HiWAAY Internet Services
I don't speak for anybody but myself - that's enough trouble.
