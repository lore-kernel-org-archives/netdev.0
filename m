From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v3 1/5] net: don't reforward packets already
 forwarded by offload device
Date: Mon, 20 Jul 2015 09:21:40 +0200
Message-ID: <55ACA184.1020007@6wind.com>
References: <1437269092-17669-1-git-send-email-sfeldma@gmail.com> <1437269092-17669-2-git-send-email-sfeldma@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com,
	simon.horman@netronome.com
To: sfeldma@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:37812 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755480AbbGTHVn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 03:21:43 -0400
Received: by wibud3 with SMTP id ud3so88407330wib.0
        for <netdev@vger.kernel.org>; Mon, 20 Jul 2015 00:21:42 -0700 (PDT)
In-Reply-To: <1437269092-17669-2-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 19/07/2015 03:24, sfeldma@gmail.com a =C3=A9crit :
> From: Scott Feldman <sfeldma@gmail.com>
>
> Just before queuing skb for xmit on port, check if skb has been marke=
d by
> switchdev port driver as already fordwarded by device.  If so, drop s=
kb.  A
> non-zero skb->offload_fwd_mark field is set by the switchdev port
> driver/device on ingress to indicate the skb has already been forward=
ed by
> the device to egress ports with matching dev->skb_mark.  The switchde=
v port
> driver would assign a non-zero dev->offload_skb_mark for each device =
port
> netdev during registration, for example.
>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> Acked-by: Jiri Pirko <jiri@resnulli.us>
> Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
