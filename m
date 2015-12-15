From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net] skbuff: Fix offset error in skb_reorder_vlan_header
Date: Tue, 15 Dec 2015 15:57:44 +0100
Message-ID: <56702A68.8000600@6wind.com>
References: <566ED772.8070600@6wind.com>
 <1450133050-24636-1-git-send-email-vyasevich@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>
To: Vladislav Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:38645 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751996AbbLOO5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 09:57:47 -0500
Received: by mail-wm0-f50.google.com with SMTP id p66so29437386wmp.1
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 06:57:47 -0800 (PST)
In-Reply-To: <1450133050-24636-1-git-send-email-vyasevich@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 14/12/2015 23:44, Vladislav Yasevich a =C3=A9crit :
> skb_reorder_vlan_header is called after the vlan header has
> been pulled.  As a result the offset of the begining of
> the mac header has been incrased by 4 bytes (VLAN_HLEN).
> When moving the mac addresses, include this incrase in
> the offset calcualation so that the mac addresses are
> copied correctly.
>
> Fixes: a6e18ff1117 (vlan: Fix untag operations of stacked vlans with =
REORDER_HEADER off)
> CC: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> CC: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Vladislav Yasevich <vyasevich@gmail.com>
Thank you for the fix. A bit late, but for the record:

Tested-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
