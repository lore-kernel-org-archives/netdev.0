From: David Miller <davem@davemloft.net>
Subject: Re: [Patch]8139too: remove unnecessary cast of ioread32()'s return
 value
Date: Sun, 30 May 2010 18:35:57 -0700 (PDT)
Message-ID: <20100530.183557.104047217.davem@davemloft.net>
References: <20100530.153451.193700815.davem@davemloft.net>
	<4C02F3A2.90100@garzik.org>
	<20100530.182948.71104948.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40438
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755234Ab0EaBfr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 May 2010 21:35:47 -0400
In-Reply-To: <20100530.182948.71104948.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sun, 30 May 2010 18:29:48 -0700 (PDT)

> From: Jeff Garzik <jeff@garzik.org>
> Date: Sun, 30 May 2010 19:24:18 -0400
> 
>> That was the genesis of the question.  Some arches still use unsigned
>> long.
> 
> They are 32-bit.

In fact the only two offenders are h8300 and m32r, which are
both 32-bit.

This is really in the realm of "who cares."
