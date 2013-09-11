From: Josh Boyer <jwboyer@fedoraproject.org>
Subject: Re: 3.10.0 network trace
Date: Wed, 11 Sep 2013 08:49:36 -0400
Message-ID: <CA+5PVA5bDAz5a-TrM4ALA9vJz2JbE14VT7xM5=WqaRg=Ro0_xQ@mail.gmail.com>
References: <CA+rTEUPfP8ouJHbaFrO=-zktg2D06kYgXOq-LnmyKbbEzj-TmA@mail.gmail.com>
	<CA+rTEUMYihwm_5ado5q1ZrYovgM6=Yc99mSaO-dNUyj4XyTj_Q@mail.gmail.com>
	<CAK6E8=eNa72=LySKsgpnKd5A6CSkr0pbpet1X2g8em9Or=m7bg@mail.gmail.com>
	<CA+rTEUNfHvr-Zs1JWVQV+_7ygW5AP9UScePSBEM-dsi0h7nS=w@mail.gmail.com>
	<CAK6E8=eqFm5_nDMdzkt6WUJXmKVTOyGbt-WtVPHDWdrOdYK_Ow@mail.gmail.com>
	<CA+rTEUNkqngK5cTUPPKAYkNgF4P8JcHoRoaEgUzBUTvO+h5JXQ@mail.gmail.com>
	<CAK6E8=fefVLUorMKCqJGSnq6Sc9LOKp7eUyOnh6h8rcOcJtQNQ@mail.gmail.com>
	<CA+rTEUOXAH4TGMGvgBJ6FktA6E=hFhQmFHRf4Zaw5YJ6giOpOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Yuchung Cheng <ycheng@google.com>, netdev <netdev@vger.kernel.org>
To: Michael Sterrett <michael@sterretts.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:43099 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752507Ab3IKMth (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 08:49:37 -0400
Received: by mail-ob0-f169.google.com with SMTP id es8so8503600obc.14
        for <netdev@vger.kernel.org>; Wed, 11 Sep 2013 05:49:37 -0700 (PDT)
In-Reply-To: <CA+rTEUOXAH4TGMGvgBJ6FktA6E=hFhQmFHRf4Zaw5YJ6giOpOA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 21, 2013 at 9:36 PM, Michael Sterrett <michael@sterretts.net> wrote:
> Since upgraded to 3.10.1 which exhibits the same issue (probably not
> surprising).
>
> sysctl net.ipv4.tcp_frto=0 net.ipv4.tcp_early_retrans=3 seems to take
> care of it.

We're still getting reports of this with 3.10.10 in Fedora [1].  At
least one of the reporters has said those sysctl settings didn't help.

Is there anything else that can be gathered to help track this down?

josh

[1] https://bugzilla.redhat.com/show_bug.cgi?id=989251
