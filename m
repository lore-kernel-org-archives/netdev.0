From: Yuchung Cheng <ycheng@google.com>
Subject: Re: 3.10.0 network trace
Date: Fri, 12 Jul 2013 14:39:34 -0700
Message-ID: <CAK6E8=eqFm5_nDMdzkt6WUJXmKVTOyGbt-WtVPHDWdrOdYK_Ow@mail.gmail.com>
References: <CA+rTEUPfP8ouJHbaFrO=-zktg2D06kYgXOq-LnmyKbbEzj-TmA@mail.gmail.com>
 <CA+rTEUMYihwm_5ado5q1ZrYovgM6=Yc99mSaO-dNUyj4XyTj_Q@mail.gmail.com>
 <CAK6E8=eNa72=LySKsgpnKd5A6CSkr0pbpet1X2g8em9Or=m7bg@mail.gmail.com> <CA+rTEUNfHvr-Zs1JWVQV+_7ygW5AP9UScePSBEM-dsi0h7nS=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Michael Sterrett <michael@sterretts.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:63381 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932919Ab3GLVj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jul 2013 17:39:58 -0400
Received: by mail-la0-f48.google.com with SMTP id lx15so8120808lab.35
        for <netdev@vger.kernel.org>; Fri, 12 Jul 2013 14:39:56 -0700 (PDT)
In-Reply-To: <CA+rTEUNfHvr-Zs1JWVQV+_7ygW5AP9UScePSBEM-dsi0h7nS=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 12, 2013 at 2:33 PM, Michael Sterrett <michael@sterretts.net> wrote:
> Thanks for the reply.  The sysctl -a output is attached.

Hi Michael: my guess is some of the recent changes like TLP or F-RTO
rewrite has bugs. It'd be best if you can provide tcp traces that
triggers this. If not and this WARN appears frequently enough, please
try i) sysctl tcp_early_retrans=2 ii) sysctl tcp_frto=0 and see if
that WARN goes away. Thanks.
