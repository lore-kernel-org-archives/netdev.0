From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 1/1] NET: usb: cdc_mbim: add quirk for supporting Telit LE922A
Date: Wed, 07 Dec 2016 15:27:58 +0100
Message-ID: <87vauvstjl.fsf@miraculix.mork.no>
References: <1481116068-32691-1-git-send-email-dnlplm@gmail.com>
        <1481116068-32691-2-git-send-email-dnlplm@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Oliver Neukum <oliver@neukum.org>, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org
To: Daniele Palmas <dnlplm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:41111 "EHLO canardo.mork.no"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752245AbcLGO2R (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 09:28:17 -0500
In-Reply-To: <1481116068-32691-2-git-send-email-dnlplm@gmail.com> (Daniele
        Palmas's message of "Wed, 7 Dec 2016 14:07:48 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniele Palmas <dnlplm@gmail.com> writes:

> Telit LE922A MBIM based composition does not work properly
> with altsetting toggle done in cdc_ncm_bind_common.
>
> This patch adds CDC_MBIM_FLAG_AVOID_ALTSETTING_TOGGLE quirk
> to avoid this procedure that, instead, is mandatory for
> other modems.
>
> Signed-off-by: Daniele Palmas <dnlplm@gmail.com>

Thanks.  This looks as nice as we can possibly do for now.  I am happy
to add

Reviewed-by: Bj=C3=B8rn Mork <bjorn@mork.no>


This patch also helped me understanding the problem you face even
better: It's not the "set_altsetting 0" that's causing problems, but the
"set_altsetting X" prior to that.  And that is certainly not something
that a firmware should expect. I will look at the Huawei modem again
when I get some time and see if there is any way we can possibly avoid
it.




Bj=C3=B8rn
