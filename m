From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: NETDEV_FEAT_CHANGE and ethtool (question)
Date: Sun, 12 May 2013 21:18:46 +0200
Message-ID: <CAHXqBFKwFtM03jg_UqbpHqg2fod_R2gYBHPqJ9YQMmE=ZF68Hw@mail.gmail.com>
References: <CAF0Lin3mWT_GybiXE1AihZj8iRfmQ7ahNg51SHn6BKtbitFm4A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Andy Johnson <johnsonzjo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f171.google.com ([209.85.210.171]:54940 "EHLO
	mail-ia0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350Ab3ELTTH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 May 2013 15:19:07 -0400
Received: by mail-ia0-f171.google.com with SMTP id r13so6767672iar.2
        for <netdev@vger.kernel.org>; Sun, 12 May 2013 12:19:06 -0700 (PDT)
In-Reply-To: <CAF0Lin3mWT_GybiXE1AihZj8iRfmQ7ahNg51SHn6BKtbitFm4A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/5/12 Andy Johnson <johnsonzjo@gmail.com>:
> Hello,
>
> The only thing that netdev_features_change() does is send
> NETDEV_FEAT_CHANGE event
> notification.
>
> NETDEV_FEAT_CHANGE event is sent in the core from
> netdev_update_features() if __netdev_update_features returned 1, and
> this event is *always* sent from netdev_change_features().
>
> ethtool calls __netdev_update_features() when chaning features. So
> changing GSO offload features for example, by
> "ethtool -K gso off" will *not* trigger NETDEV_FEAT_CHANGE event noti=
fication.
> (assuming that ndo_fix_features/ndo_set_features callbacks of the
> driver, if exist, will not
> trigger such noticiation call).
>
> My question is: why changing features by ethtool does not trigger
> sending NETDEV_FEAT_CHANGE event?

You didn't verify this assumption. See dev_ethtool()'s last check.

Best Regards,
Micha=C5=82 Miros=C5=82aw
