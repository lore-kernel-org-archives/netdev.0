From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6 8/8] net: get rid of orig_dev parameter of
 packet handlers
Date: Sat, 05 Mar 2011 16:05:16 +0100
Message-ID: <4D72512C.2060802@gmail.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com> <1299320969-7951-9-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39740 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957Ab1CEPFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2011 10:05:20 -0500
Received: by wyg36 with SMTP id 36so3022456wyg.19
        for <netdev@vger.kernel.org>; Sat, 05 Mar 2011 07:05:18 -0800 (PST)
In-Reply-To: <1299320969-7951-9-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/03/2011 11:29, Jiri Pirko a =E9crit :
> Since orig_dev was used in af_packet (where it was replaced) and by
> bonding ptype handlers (which are no longer with us) only, orig_dev
> parameter is no longer needed ->  toss it out
>
> Signed-off-by: Jiri Pirko<jpirko@redhat.com>

[snip]
> -	new->deliver_no_wcard	=3D old->deliver_no_wcard;

deliver_no_wcard was removed from sk_buff in your #7 patch. Shouldn't t=
he above line be part of the=20
#7 patch?

Except from this point,

Reviewed-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>

	Nicolas.
