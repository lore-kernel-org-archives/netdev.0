From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: KS8851 needs to depend on MII
Date: Wed, 22 Jul 2009 09:33:22 -0700 (PDT)
Message-ID: <20090722.093322.129084266.davem@davemloft.net>
References: <1248261411-12533-1-git-send-email-a.beregalov@gmail.com>
	<4A66F5B5.2050606@simtec.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: a.beregalov@gmail.com, netdev@vger.kernel.org
To: ben@simtec.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44510
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751731AbZGVQdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2009 12:33:16 -0400
In-Reply-To: <4A66F5B5.2050606@simtec.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Dooks <ben@simtec.co.uk>
Date: Wed, 22 Jul 2009 12:19:17 +0100

> Alexander Beregalov wrote:
>> fix this build error when CONFIG_MII is not set
>> drivers/net/ks8851.c:999: undefined reference to `generic_mii_ioctl'
>> drivers/net/ks8851.c:1050: undefined reference to `mii_link_ok'
>> drivers/net/ks8851.c:1056: undefined reference to `mii_nway_restart'
>> drivers/net/ks8851.c:1044: undefined reference to `mii_ethtool_sset'
>> drivers/net/ks8851.c:1038: undefined reference to `mii_ethtool_gset'
> 
> thanks, my test system has an DM9000 so that selected CONFIG_MII for
> me.
> 
>> Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
> Acked-by: Ben Dooks <ben@simtec.co.uk>

Applied, thanks.
