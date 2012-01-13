From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: [0/5] bcma/brcmsmac suspend/resume cleanups and fixes
Date: Thu, 12 Jan 2012 23:59:22 -0800 (PST)
Message-ID: <alpine.LNX.2.00.1201122354430.5860@air.linux-foundation.org>
References: <CA+55aFzm21ZKs7e_ocVA1bQQ=Js2dJpbiycwHR3v8yNvb0MgTw@mail.gmail.com> <1326440480-26271-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Arend van Spriel <arend@broadcom.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Alwin Beukers <alwin@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: =?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:40713 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751196Ab2AMH6u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 02:58:50 -0500
Received: by iabz25 with SMTP id z25so3982964iab.19
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2012 23:58:50 -0800 (PST)
In-Reply-To: <1326440480-26271-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


So here are five cleanup/fix patches that try to make the bcma and=20
brcmsmac suspend/resume situation look better.

The changes do:

 - use the modern PCI suspend/resume model, and let the PCI layer handl=
e=20
   the actual standard power state changes.

 - clean up the BCMA suspend/resume infrastructure a bit in general.

 - actually hook the BCMA suspend/resume callbacks up to the=20
   suspend/resume event - it use to be that a bcma driver could set its=
=20
   suspend/resume routines, but nothing would ever call them.

 - and Rafa=B3's bcma window invalidation

Comments? This gets suspend/resume working for me at least once. I'm no=
t=20
going to try to hang my machine again until after I have gotten this se=
nt=20
out.

Does this work for others?

               Linus
