From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][FIX 4.1] bgmac: fix requests for extra polling calls
 from NAPI
Date: Fri, 24 Apr 2015 11:32:03 -0400 (EDT)
Message-ID: <20150424.113203.653089953794770127.davem@davemloft.net>
References: <1429815389-17265-1-git-send-email-zajec5@gmail.com>
	<55394134.3070505@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zajec5@gmail.com, netdev@vger.kernel.org, eric.dumazet@gmail.com,
	hauke@hauke-m.de
To: nbd@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51044 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932218AbbDXPcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 11:32:05 -0400
In-Reply-To: <55394134.3070505@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Felix Fietkau <nbd@openwrt.org>
Date: Thu, 23 Apr 2015 21:00:04 +0200

> On 2015-04-23 20:56, Rafa=A9=A9 Mi=A9=A9ecki wrote:
>> After d75b1ade567f ("net: less interrupt masking in NAPI") polling
>> function has to return whole budget when it wants NAPI to call it ag=
ain.
>>=20
>> Signed-off-by: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>
>> Cc: Felix Fietkau <nbd@openwrt.org>
>> Fixes: eb64e2923a886 ("bgmac: leave interrupts disabled as long as t=
here is work to do")
> Acked-by: Felix Fietkau <nbd@openwrt.org>

Applied, thanks everyone.
