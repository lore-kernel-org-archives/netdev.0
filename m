From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/7] bonding: use table for mode names
Date: Tue, 09 Dec 2008 23:08:16 -0800 (PST)
Message-ID: <20081209.230816.53700487.davem@davemloft.net>
References: <20081209200750.490739902@eitzenberger.org>
	<20081209201446.222212807@eitzenberger.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, netdev@vger.kernel.org
To: holger@eitzenberger.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39293
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753640AbYLJHIP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 02:08:15 -0500
In-Reply-To: <20081209201446.222212807@eitzenberger.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: holger@eitzenberger.org
Date: Tue, 09 Dec 2008 21:07:52 +0100

> Use a small array in bond_mode_name() for the names, thus saving some
> space:
> 
> before
> 
>     text     data      bss      dec    hex filename
>    57736     9372      344    67452  1077c drivers/net/bonding/bonding.ko
> 
> after
>     text     data      bss      dec    hex filename
>    57441     9372      344    67157  10655 drivers/net/bonding/bonding.ko
> 
> Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Applied.
