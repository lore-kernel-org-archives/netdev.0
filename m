From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: added 802.3ad round-robin hashing policy and
 source mac selection mode
Date: Sun, 27 Feb 2011 16:08:23 -0800 (PST)
Message-ID: <20110227.160823.35047612.davem@davemloft.net>
References: <20110216191341.GA14920@yandex-team.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com
To: olegu@yandex-team.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40051
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751833Ab1B1AHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Feb 2011 19:07:46 -0500
In-Reply-To: <20110216191341.GA14920@yandex-team.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Oleg V. Ukhno" <olegu@yandex-team.ru>
Date: Wed, 16 Feb 2011 22:13:41 +0300

> Patch introduces two new (related) features to bonding module.
> First feature is round-robin hashing policy, which is primarily
> intended for use with 802.3ad mode, and puts every next IPv4 and
> IPv6 packet into  next availables slave without taling into account
> which layer3 and above protocol is used.
> Second feature makes possible choosing which MAC-address will be set
> in the transmitted packet - when set to src-mac it will force setting
> slave's interface real MAC address as source MAC address in every
> packet, sent via this slave interface.

Can we get some feedback on this patch from bonding folks?

I'm not applying it blinding without at least one bonding developer
saying it at least looks ok.

Thanks.
