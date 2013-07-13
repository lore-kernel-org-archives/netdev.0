From: Michael Sterrett <michael@sterretts.net>
Subject: Re: 3.10.0 network trace
Date: Sat, 13 Jul 2013 17:10:52 -0400
Message-ID: <CA+rTEUNkqngK5cTUPPKAYkNgF4P8JcHoRoaEgUzBUTvO+h5JXQ@mail.gmail.com>
References: <CA+rTEUPfP8ouJHbaFrO=-zktg2D06kYgXOq-LnmyKbbEzj-TmA@mail.gmail.com>
	<CA+rTEUMYihwm_5ado5q1ZrYovgM6=Yc99mSaO-dNUyj4XyTj_Q@mail.gmail.com>
	<CAK6E8=eNa72=LySKsgpnKd5A6CSkr0pbpet1X2g8em9Or=m7bg@mail.gmail.com>
	<CA+rTEUNfHvr-Zs1JWVQV+_7ygW5AP9UScePSBEM-dsi0h7nS=w@mail.gmail.com>
	<CAK6E8=eqFm5_nDMdzkt6WUJXmKVTOyGbt-WtVPHDWdrOdYK_Ow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:64564 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925Ab3GMVKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jul 2013 17:10:53 -0400
Received: by mail-pd0-f174.google.com with SMTP id 10so9603956pdc.19
        for <netdev@vger.kernel.org>; Sat, 13 Jul 2013 14:10:52 -0700 (PDT)
In-Reply-To: <CAK6E8=eqFm5_nDMdzkt6WUJXmKVTOyGbt-WtVPHDWdrOdYK_Ow@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After changing those two sysctl settings the WARN hasn't reappeared.
I'm willing to mess around with this box though if you want to try to
narrow down the root cause with different settings and/or patches.

On Fri, Jul 12, 2013 at 5:39 PM, Yuchung Cheng <ycheng@google.com> wrote:
> On Fri, Jul 12, 2013 at 2:33 PM, Michael Sterrett <michael@sterretts.net> wrote:
>> Thanks for the reply.  The sysctl -a output is attached.
>
> Hi Michael: my guess is some of the recent changes like TLP or F-RTO
> rewrite has bugs. It'd be best if you can provide tcp traces that
> triggers this. If not and this WARN appears frequently enough, please
> try i) sysctl tcp_early_retrans=2 ii) sysctl tcp_frto=0 and see if
> that WARN goes away. Thanks.
