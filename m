From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for October 13 (net/3c59x)
Date: Wed, 13 Oct 2010 09:54:32 -0700 (PDT)
Message-ID: <20101013.095432.71126747.davem@davemloft.net>
References: <20101013154522.7b087a20.sfr@canb.auug.org.au>
	<20101013093836.1ee6f2f9.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45829
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750933Ab0JMQyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 12:54:10 -0400
In-Reply-To: <20101013093836.1ee6f2f9.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Wed, 13 Oct 2010 09:38:36 -0700

> On Wed, 13 Oct 2010 15:45:22 +1100 Stephen Rothwell wrote:
> 
>> Hi all,
>> 
>> Changes since 20101012:
> 
> 
> when CONFIG_PCI is not enabled:
> 
> drivers/net/3c59x.c:3211: error:request for member 'current_state' in something not a structure or union

Like all the other PCI interfaces that NOP out into empty inlines when
CONFIG_PCI is not enabled, it would be nice to have an interface that
provides pci_dev->current_state in a similar fashion so we don't have
to add a bunch of ifdefs here.
