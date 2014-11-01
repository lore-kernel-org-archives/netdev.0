From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: mv643xx_eth: Make TSO disabled by default
Date: Sat, 01 Nov 2014 13:40:40 -0400 (EDT)
Message-ID: <20141101.134040.2199591301326553094.davem@davemloft.net>
References: <1414855820-15094-1-git-send-email-ezequiel.garcia@free-electrons.com>
	<1414855820-15094-2-git-send-email-ezequiel.garcia@free-electrons.com>
	<20141101180037.087b7a95@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ezequiel.garcia@free-electrons.com, netdev@vger.kernel.org,
	gregory.clement@free-electrons.com, tawfik@marvell.com,
	alior@marvell.com, nadavh@marvell.com
To: thomas.petazzoni@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54404 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752499AbaKARkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Nov 2014 13:40:42 -0400
In-Reply-To: <20141101180037.087b7a95@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Date: Sat, 1 Nov 2014 18:00:37 +0100

> Dear Ezequiel Garcia,
> 
> On Sat,  1 Nov 2014 12:30:20 -0300, Ezequiel Garcia wrote:
>> Data corruption has been observed to be produced by TSO. For instance,
>> accessing files on a NFS-server with TSO enabled results in different data
>> transferred each time.
>> 
>> This has been observed only on Kirkwood platforms, i.e. with the mv643xx_eth
>> driver. Same tests on platforms using the mvneta ethernet driver have
>> passed without errors.
>> 
>> Make TSO disabled by default for now, until we can found a proper fix
>> for the regression.
>> 
>> Fixes: 3ae8f4e0b98 ('net: mv643xx_eth: Implement software TSO')
>> Reported-by: Slawomir Gajzner <slawomir.gajzner@gmail.com>
>> Reported-by: Julien D'Ascenzio <jdascenzio@yahoo.fr>
>> Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
> 
> Shouldn't you have a:
> 
>    Cc: <stable@vger.kernel.org> # v3.16+

Networking patches do not get sent to -stable that way.

Instead, people specifically request that I queue up the change
for -stable and I submit it by hand at the appropriate time.
