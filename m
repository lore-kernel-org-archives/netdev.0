From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [patch sungem] improved locking
Date: Wed, 29 Nov 2006 11:19:34 +1100
Message-ID: <1164759574.5350.115.camel@localhost.localdomain>
References: <5cac192f0611141354l3a4aa130ve741c9d6a7a49d0a@mail.gmail.com>
	 <20061128.144911.55733883.davem@davemloft.net>
	 <1164754644.5350.110.camel@localhost.localdomain>
	 <20061128.154350.02290212.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eric.lemoine@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:7597 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S1755714AbWK2ATm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Nov 2006 19:19:42 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061128.154350.02290212.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-11-28 at 15:43 -0800, David Miller wrote:

> At least in theory the atomic + any necessary memory barriers
> would be cheaper than the extra PIO read we need otherwise.

Yes, IO reads are generally the worst case scenarios even on machines
with fairly slow locks.

Ben.


