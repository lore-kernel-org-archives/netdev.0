From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [patch net-next] net: make packet_type->ak_packet_priv generic
Date: Fri, 04 Apr 2014 14:58:24 +0200
Message-ID: <533EAC70.2070604@6wind.com>
References: <1396614038-31975-1-git-send-email-jiri@resnulli.us>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, edumazet@google.com, vfalico@redhat.com,
	stephen@networkplumber.org, hkchu@google.com, dborkman@redhat.com,
	willemb@google.com, hannes@stressinduktion.org,
	atzm@stratosphere.co.jp, phil@nwl.cc, richardcochran@gmail.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:46518 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752388AbaDDM63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 08:58:29 -0400
Received: by mail-wg0-f43.google.com with SMTP id x13so3357538wgg.26
        for <netdev@vger.kernel.org>; Fri, 04 Apr 2014 05:58:27 -0700 (PDT)
In-Reply-To: <1396614038-31975-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/04/2014 14:20, Jiri Pirko a =C3=A9crit :
> The priv is used now by af_packet. Rename it to make it useable for
> others as well. Also, introduce packet_id_match to move the sk matchi=
ng
> from skb_loop_sk to af_packet code where it belongs.
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>   include/linux/netdevice.h |  2 +-
>   net/core/dev.c            |  4 +---
>   net/packet/af_packet.c    | 22 +++++++++++++++-------
>   3 files changed, 17 insertions(+), 11 deletions(-)
Hmm, net-next is closed I think.
