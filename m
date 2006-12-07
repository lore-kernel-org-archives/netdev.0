From: David Miller <davem@davemloft.net>
Subject: Re: [AX.25] Fix default address and broadcast address
 initialization
Date: Thu, 07 Dec 2006 15:47:22 -0800 (PST)
Message-ID: <20061207.154722.18578387.davem@davemloft.net>
References: <20061207234057.GA15220@linux-mips.org>
	<20061207234559.GA15282@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35406
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1164016AbWLGXrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 18:47:08 -0500
To: ralf@linux-mips.org
In-Reply-To: <20061207234559.GA15282@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Thu, 7 Dec 2006 23:45:59 +0000

> Only the callsign but not the SSID part of an AX.25 address is ASCII
> based but Linux by initializes the SSID which should be just a 4-bit
> number from ASCII anyway.
> 
> Fix that and convert the code to use a shared constant for both default
> addresses.  While at it, use the same style for null_ax25_address also.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Applied, thanks Ralf.
