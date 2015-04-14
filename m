From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH v5 4/9] bgmac: simplify rx DMA error handling
Date: Tue, 14 Apr 2015 02:05:18 +0200
Message-ID: <552C59BE.4010506@openwrt.org>
References: <1428946067-75650-1-git-send-email-nbd@openwrt.org>	<1428946067-75650-4-git-send-email-nbd@openwrt.org>	<20150413232040.GA30799@electric-eye.fr.zoreil.com> <20150413.200408.109329017927025696.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zajec5@gmail.com, hauke@hauke-m.de
To: David Miller <davem@davemloft.net>, romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:33585 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752090AbbDNAFX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 20:05:23 -0400
In-Reply-To: <20150413.200408.109329017927025696.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-04-14 02:04, David Miller wrote:
> From: Francois Romieu <romieu@fr.zoreil.com>
> Date: Tue, 14 Apr 2015 01:20:40 +0200
> 
>> Felix Fietkau <nbd@openwrt.org> :
>>> Unmap the DMA buffer before checking it. If an error occurs, free the
>>> buffer and allocate a new one. If allocation or mapping fails, retry as
>>> long as there is NAPI poll budget left (count every attempt instead of
>>> every frame).
>> 
>> The driver is not supposed to use the NAPI budget this way.
>> 
>> If the driver can't reserve resources to handle the packet, it should
>> drop the data, keep everything in place for the hardware and move to the
>> next slot.
> 
> +1
Fixed in v6.

- Felix
