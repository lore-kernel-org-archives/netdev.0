From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/2] be2net: Adding an option to use INTx
 instead of MSI-X
Date: Mon, 25 Oct 2010 12:09:43 -0700 (PDT)
Message-ID: <20101025.120943.189699949.davem@davemloft.net>
References: <20101025111235.GA2024@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: somnath.kotur@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46219
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932906Ab0JYTJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 15:09:21 -0400
In-Reply-To: <20101025111235.GA2024@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>
Date: Mon, 25 Oct 2010 16:42:35 +0530

> By default, be2net uses MSIx wherever possible.
> Adding a module parameter to use INTx for users who do not want to use MSIx.
> 
> Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>

Either add a new ethtool flag, or use the PCI subsystem facilities
for tweaking things to implement this.

Do not use a module option, otherwise every other networking driver
author will get the same "cool" idea, give the module option
different names, and the resulting user experience is terrible.
