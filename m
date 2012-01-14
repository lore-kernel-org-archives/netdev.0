From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [0/5] bcma/brcmsmac suspend/resume cleanups and fixes
Date: Fri, 13 Jan 2012 19:50:21 -0800
Message-ID: <CA+55aFxtaw+FF8wRf9td1rU0A_vhM8XwgSznzE-ph_4j=t5gWg@mail.gmail.com>
References: <CA+55aFzm21ZKs7e_ocVA1bQQ=Js2dJpbiycwHR3v8yNvb0MgTw@mail.gmail.com>
 <1326440480-26271-1-git-send-email-zajec5@gmail.com> <alpine.LNX.2.00.1201122354430.5860@air.linux-foundation.org>
 <4F101047.4090902@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: =?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Alwin Beukers <alwin@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:40835 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754158Ab2ANDuo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 22:50:44 -0500
Received: by werb13 with SMTP id b13so859270wer.19
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2012 19:50:43 -0800 (PST)
In-Reply-To: <4F101047.4090902@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/1/13 Arend van Spriel <arend@broadcom.com>:
>
> Upon suspend my laptop hangs (see trace below pulled from serial
> console). I do not see the pr_debug in the suspend function (compiled
> with -DDEBUG). Unfortunately the same happens when I don't insert bcma
> and brcmsmac. I attached the kernel configuration.

Ok, I note that you do have MCE enabled.

The MCE problems should be fixed in current -git, and so it might be
worth re-testing with that.

                   Linus
