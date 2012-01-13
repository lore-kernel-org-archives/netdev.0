From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [0/5] bcma/brcmsmac suspend/resume cleanups and fixes
Date: Fri, 13 Jan 2012 08:15:21 -0800
Message-ID: <CA+55aFwPT2CZ8AXLwKBvBLKT4RFyAjbniuOJ83_nFMCU58hgXw@mail.gmail.com>
References: <CA+55aFzm21ZKs7e_ocVA1bQQ=Js2dJpbiycwHR3v8yNvb0MgTw@mail.gmail.com>
 <1326440480-26271-1-git-send-email-zajec5@gmail.com> <alpine.LNX.2.00.1201122354430.5860@air.linux-foundation.org>
 <CACna6rypt6ocF2ysyDMeCFsBXye24sTTEvRi63hiosUDVGS_RQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arend van Spriel <arend@broadcom.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Alwin Beukers <alwin@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: =?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:56706 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752340Ab2AMQPm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 11:15:42 -0500
Received: by wibhm14 with SMTP id hm14so502840wib.19
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2012 08:15:41 -0800 (PST)
In-Reply-To: <CACna6rypt6ocF2ysyDMeCFsBXye24sTTEvRi63hiosUDVGS_RQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/1/13 Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>:
>
> I have Asus netbook with BCM4313 since a week, so I'll able to test
> this. Just give me a day when I'm back home.
>
> Could we rearrange order of patches to make
> bcma: invalidate the mapped window over suspend/resume
> this first one and add stable as CC? What do you think about this?

I don't think it is relevant for stable - partly because in stable the
bcma suspend/resume isn't wired up anyway, but mostly because if that
patch really wants to make it into stable, it really is a different
patch than the one I munged it into. The stable bcma doesn't have
bcma_bus_suspend() at all, so it goes into that pci-specific one like
your original email had it, where it's a complete hack.

Does it fix anything in stable?

                     Linus
