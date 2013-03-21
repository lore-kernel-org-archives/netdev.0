From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gro: relax ID check in inet_gro_receive()
Date: Thu, 21 Mar 2013 10:56:39 -0400 (EDT)
Message-ID: <20130321.105639.2282437815036262862.davem@davemloft.net>
References: <1363841553.3333.47.camel@edumazet-glaptop>
	<CANP3RGfWh1PVavxd-5gy1KvocgRiTNcm-bYZ=aMG6N6vPgyWnw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	dmitry@broadcom.com, eilong@broadcom.com, pshelar@nicira.com,
	hkchu@google.com
To: maze@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42959 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932294Ab3CUO4l convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 10:56:41 -0400
In-Reply-To: <CANP3RGfWh1PVavxd-5gy1KvocgRiTNcm-bYZ=aMG6N6vPgyWnw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <maze@google.com>
Date: Thu, 21 Mar 2013 02:59:49 -0700

> TCP packets are DF.
> AFAICT, the IP identifier field does not really serve a useful purpos=
e
> for non-fragment-ed/able packets.

Not incrementing it by one each frame breaks serial line TCP header
compression.
