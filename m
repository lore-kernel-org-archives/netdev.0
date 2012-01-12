From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: brcm80211 breakage..
Date: Wed, 11 Jan 2012 21:20:45 -0800
Message-ID: <CA+55aFw0XArx0jpNh4dWYFmvJbb+GJYAWRUN2Ec14oREiATo7g@mail.gmail.com>
References: <CA+55aFxw5e3EYCGYjkWiTmhy9-WaY4T_-MF7EYcn4jXuBoxAgw@mail.gmail.com>
 <4F0D6806.4080201@broadcom.com> <CA+55aFxzFKkUPSCU6Wr_FBPd6NFPeTctGR0kpqYJJ8fcw+ck7w@mail.gmail.com>
 <CA+55aFw7TdNzNi86cwF4o6xSWnbKuPS5CuhdbChzoboNw_1-Tw@mail.gmail.com>
 <4F0DC030.6090500@lwfinger.net> <CA+55aFyAX_OdE7yNp1vM1AmywrYZ9Pvr0EX47jNQciZKOQUQHg@mail.gmail.com>
 <4F0E3B7E.8040005@lwfinger.net> <CA+55aFyR9C8GjhKb8orr1kgd_G23=-mcmT-uz9zJd6wk7rYDPA@mail.gmail.com>
 <4F0E5E57.9060204@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Arend van Spriel <arend@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	=?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:52623 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951Ab2ALFVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 00:21:09 -0500
Received: by wibhm14 with SMTP id hm14so927851wib.19
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2012 21:21:07 -0800 (PST)
In-Reply-To: <4F0E5E57.9060204@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 11, 2012 at 8:15 PM, Larry Finger <Larry.Finger@lwfinger.net> wrote:
>
> I see no difference in the core revisions, etc. to explain why mine should
> work, and yours fail.

Maybe your BIOS firmware sets things up, and the Apple Macbook Air
doesn't? And the driver used to initialize things sufficiently, and
the changes have broken that?

Apple is famous for being contrary. They tend to wire things up oddly,
they don't initialize things in the BIOS (they don't have a BIOS at
all, they use EFI, but even there they use their own abortion of an
EFI rather than what everybody else does), yadda yadda.

But the real point is: it used to work, and now it doesn't. This needs
to  get fixed, or it will get reverted.

                             Linus
