From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] ehea: Fix mem allocations which require page
 alignment
Date: Wed, 21 Jan 2009 14:46:06 -0800 (PST)
Message-ID: <20090121.144606.230078300.davem@davemloft.net>
References: <200901211549.21066.tklein@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, raisch@de.ibm.com, ossthema@de.ibm.com,
	themann@de.ibm.com, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, hering2@de.ibm.com
To: tklein@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34789
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753467AbZAUWqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 17:46:04 -0500
In-Reply-To: <200901211549.21066.tklein@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Klein <tklein@de.ibm.com>
Date: Wed, 21 Jan 2009 15:49:20 +0100

> PAGE_SIZE allocations via slab are not guaranteed to be page-aligned. Fixed
> all memory allocations where page alignment is required by firmware.
> 
> Signed-off-by: Thomas Klein <tklein@de.ibm.com>

Applied.
