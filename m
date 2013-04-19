From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 5/6] net: vlan: add 802.1ad support
Date: Fri, 19 Apr 2013 22:45:03 +0200
Message-ID: <0f54a08d-f3d8-435f-b2f3-09f36858280f@email.android.com>
References: <1366373072-19621-1-git-send-email-kaber@trash.net> <1366373072-19621-6-git-send-email-kaber@trash.net> <1366401783.2716.10.camel@bwh-desktop.uk.solarflarecom.com> <20130419.160848.369413926403305345.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49562 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754203Ab3DSUpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 16:45:15 -0400
In-Reply-To: <20130419.160848.369413926403305345.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



David Miller <davem@davemloft.net> schrieb:

>From: Ben Hutchings <bhutchings@solarflare.com>
>Date: Fri, 19 Apr 2013 21:03:03 +0100
>
>> These need to be given names in the netdev_features_strings array in
>> net/core/ethtool.c
>
>Thanks, I'm about to commit the following:
>
>====================
>[PATCH] net: Add missing netdev feature strings for
>NETIF_F_HW_VLAN_STAG_*
>
>Noticed by Ben Hutchings.
>
>Signed-off-by: David S. Miller <davem@davemloft.net>
>---
> net/core/ethtool.c | 3 +++
> 1 file changed, 3 insertions(+)
>
>diff --git a/net/core/ethtool.c b/net/core/ethtool.c
>index b87712c..5a934ef 100644
>--- a/net/core/ethtool.c
>+++ b/net/core/ethtool.c
>@@ -64,6 +64,9 @@ static const char
>netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
> 
> 	[NETIF_F_HW_VLAN_CTAG_RX_BIT] =  "rx-vlan-ctag-hw-parse",
> 	[NETIF_F_HW_VLAN_CTAG_FILTER_BIT] = "rx-vlan-ctag-filter",
>+	[NETIF_F_HW_VLAN_STAG_TX_BIT] =  "tx-vlan-stag-hw-insert",
>+	[NETIF_F_HW_VLAN_STAG_RX_BIT] =  "rx-vlan-stag-hw-parse",
>+	[NETIF_F_HW_VLAN_STAG_FILTER_BIT] = "rx-vlan-stag-filter",
> 	[NETIF_F_VLAN_CHALLENGED_BIT] =  "vlan-challenged",
> 	[NETIF_F_GSO_BIT] =              "tx-generic-segmentation",
> 	[NETIF_F_LLTX_BIT] =             "tx-lockless",

Thanks Dave,

there seem to be a couple of more problems. Sorry about that, I tried to enable as much drivers as possible and review everything manually, obviously I missed some problems. I'll take care of them as soon as I get home.
