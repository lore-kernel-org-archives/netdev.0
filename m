From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: brcm80211 breakage..
Date: Thu, 12 Jan 2012 14:38:44 -0800
Message-ID: <CA+55aFxMh0T1W06YHepcPAyemcR4rrxghQeRKsW3MtT+gNK9eg@mail.gmail.com>
References: <CA+55aFxw5e3EYCGYjkWiTmhy9-WaY4T_-MF7EYcn4jXuBoxAgw@mail.gmail.com>
 <4F0D6806.4080201@broadcom.com> <CA+55aFxzFKkUPSCU6Wr_FBPd6NFPeTctGR0kpqYJJ8fcw+ck7w@mail.gmail.com>
 <CA+55aFw7TdNzNi86cwF4o6xSWnbKuPS5CuhdbChzoboNw_1-Tw@mail.gmail.com>
 <4F0DC030.6090500@lwfinger.net> <CA+55aFyAX_OdE7yNp1vM1AmywrYZ9Pvr0EX47jNQciZKOQUQHg@mail.gmail.com>
 <4F0E3B7E.8040005@lwfinger.net> <CA+55aFyR9C8GjhKb8orr1kgd_G23=-mcmT-uz9zJd6wk7rYDPA@mail.gmail.com>
 <4F0E5E57.9060204@lwfinger.net> <CA+55aFw0XArx0jpNh4dWYFmvJbb+GJYAWRUN2Ec14oREiATo7g@mail.gmail.com>
 <CA+55aFxDOr_TT+kxp1SuwNFfm7KLTaWSLQwk1Fx8fWe7tdstcg@mail.gmail.com>
 <CA+55aFzkCXnHfF_TO5M+gaN4RMvj_WNuW_QeBezuYBdWnwPDpg@mail.gmail.com>
 <CA+55aFx2UnVZP1Z44dMHeifB2nD1zJ87kz25zZjUdwv0ozwKPA@mail.gmail.com>
 <CA+55aFzNJbM=ohXninJ06518e3a6E8vySg8GT6dx+Qovk1QW0Q@mail.gmail.com>
 <4F0F3DEC.4050605@broadcom.com> <CA+55aFw==r4TF5WPn5Ggz32m7yi2T71Ghdx+7ME=pEjQLqU=uw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Alwin Beukers <alwin@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	=?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:33010 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755630Ab2ALWjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 17:39:06 -0500
Received: by ghbg16 with SMTP id g16so601995ghb.19
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2012 14:39:05 -0800 (PST)
In-Reply-To: <CA+55aFw==r4TF5WPn5Ggz32m7yi2T71Ghdx+7ME=pEjQLqU=uw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 12, 2012 at 12:27 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> But I'm currently also trying to work out why that macbook air no
> longer comes back from a suspend alive, and it looks like it may be
> another problem with that brcmsmac driver. The bisection is in its
> early stages yet, but it looks like it is coming in from the network
> merge, and nothing else looks relevant.

Ugh. This is nasty to bisect, because it goes back to the pre-3.2 days
that didn't support graphics properly on that Macbook Air either. So
I've been having to work around not just the "wireless doesn't work",
but also the "graphics doesn't work" issue.

But after lots of nasty bisection problems and a few false starts, it
definitely looks like the brcmsmac driver. I don't know exactly which
commit, but it's all in network drivers now, and the only network
driver on this machine is the brcmsmac one.

                     Linus
