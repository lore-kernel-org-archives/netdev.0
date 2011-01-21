From: Po-Yu Chuang <ratbert.chuang@gmail.com>
Subject: Re: [PATCH v3] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Fri, 21 Jan 2011 11:35:37 +0800
Message-ID: <AANLkTik-d86O8EHZctzuy7=CGgTkSaD4m9Lcqh_wofEL@mail.gmail.com>
References: <1295256060-2091-1-git-send-email-ratbert.chuang@gmail.com>
 <1295537418-2057-1-git-send-email-ratbert.chuang@gmail.com> <1295546179.28001.4.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bhutchings@solarflare.com, eric.dumazet@gmail.com,
	dilinger@queued.net, Po-Yu Chuang <ratbert@faraday-tech.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:39960 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751496Ab1AUDf7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 22:35:59 -0500
In-Reply-To: <1295546179.28001.4.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Joe,

On Fri, Jan 21, 2011 at 1:56 AM, Joe Perches <joe@perches.com> wrote:
> On Thu, 2011-01-20 at 23:30 +0800, Po-Yu Chuang wrote:
>> From: Po-Yu Chuang <ratbert@faraday-tech.com>
> []
>> + =C2=A0 =C2=A0 /* map io memory */
>> + =C2=A0 =C2=A0 priv->res =3D request_mem_region(res->start, res->en=
d - res->start,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dev_name(&pd=
ev->dev));
>
> Off by one?
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0priv->res =3D request_mem_region(res->star=
t, resource_size(res),
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev_nam=
e(&pdev->dev));

=46ixed.

best regards,
Po-Yu Chuang
