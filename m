From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [net-next-2.6 PATCH v2] can: SJA1000: generic OF platform bus
 driver
Date: Mon, 25 May 2009 08:58:21 +0200
Message-ID: <4A1A418D.3040207@grandegger.com>
References: <4A16BAAE.3070401@grandegger.com> <200905231315.57016.arnd@arndb.de> <4A18298E.8090209@grandegger.com> <200905242327.15139.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	devicetree-discuss@ozlabs.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:39729 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751830AbZEYG6W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2009 02:58:22 -0400
In-Reply-To: <200905242327.15139.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann wrote:
> On Saturday 23 May 2009, Wolfgang Grandegger wrote:
>> Arnd Bergmann wrote:
>>> Minor nitpicking: dev->base_addr should be defined as an __iomem pointer
>>> so you can avoid the cast here and in the ioremap/iounmap path.
>> Here the member "base_addr" of "struct net_device" is used and it's not
>> up to me to change the type.
> 
> Right, that makes sense. However, most drivers use the field to store the
> physical address, not the iomap token. Maybe there should be a new field
> in struct sja1000_priv for the virtual address, but that would be a change
> to the base driver, not just to the OF portion.

Is that common practice? If yes, I will add a member to store the
virtual address to struct sja1000_priv.

Wolfgang.
