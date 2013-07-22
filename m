From: Michael Sterrett <michael@sterretts.net>
Subject: Re: 3.10.0 network trace
Date: Sun, 21 Jul 2013 21:36:32 -0400
Message-ID: <CA+rTEUOXAH4TGMGvgBJ6FktA6E=hFhQmFHRf4Zaw5YJ6giOpOA@mail.gmail.com>
References: <CA+rTEUPfP8ouJHbaFrO=-zktg2D06kYgXOq-LnmyKbbEzj-TmA@mail.gmail.com>
	<CA+rTEUMYihwm_5ado5q1ZrYovgM6=Yc99mSaO-dNUyj4XyTj_Q@mail.gmail.com>
	<CAK6E8=eNa72=LySKsgpnKd5A6CSkr0pbpet1X2g8em9Or=m7bg@mail.gmail.com>
	<CA+rTEUNfHvr-Zs1JWVQV+_7ygW5AP9UScePSBEM-dsi0h7nS=w@mail.gmail.com>
	<CAK6E8=eqFm5_nDMdzkt6WUJXmKVTOyGbt-WtVPHDWdrOdYK_Ow@mail.gmail.com>
	<CA+rTEUNkqngK5cTUPPKAYkNgF4P8JcHoRoaEgUzBUTvO+h5JXQ@mail.gmail.com>
	<CAK6E8=fefVLUorMKCqJGSnq6Sc9LOKp7eUyOnh6h8rcOcJtQNQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:54680 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752743Ab3GVBgd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 21:36:33 -0400
Received: by mail-pa0-f51.google.com with SMTP id lf10so107963pab.38
        for <netdev@vger.kernel.org>; Sun, 21 Jul 2013 18:36:32 -0700 (PDT)
In-Reply-To: <CAK6E8=fefVLUorMKCqJGSnq6Sc9LOKp7eUyOnh6h8rcOcJtQNQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since upgraded to 3.10.1 which exhibits the same issue (probably not
surprising).

sysctl net.ipv4.tcp_frto=0 net.ipv4.tcp_early_retrans=3 seems to take
care of it.
