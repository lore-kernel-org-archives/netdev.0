From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: fix checksum broken
Date: Wed, 17 Nov 2010 11:55:21 -0800 (PST)
Message-ID: <20101117.115521.212691733.davem@davemloft.net>
References: <20101112231325.GB6676@electric-eye.fr.zoreil.com>
	<4CE0A994.4080606@cn.fujitsu.com>
	<20101115210122.GA22621@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shanwei@cn.fujitsu.com, netdev@vger.kernel.org, jgarzik@pobox.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43658
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935285Ab0KQTy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 14:54:56 -0500
In-Reply-To: <20101115210122.GA22621@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Mon, 15 Nov 2010 22:01:23 +0100

> Shan Wei <shanwei@cn.fujitsu.com> :
> [...]
>> If these are right, driver will set ip_summed with CHECKSUM_UNNECESSARY for other
>> upper protocol, e.g. sctp, igmp protocol. This will cause protocol stack ignores 
>> checksum check for packets with invalid checksum. 
> 
> The documentation of these bits is identical for the 8139c+ and the 8169.

Also applied, thank you.
