From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/4] network dev read_mostly
Date: Thu, 15 Mar 2007 00:25:16 -0700 (PDT)
Message-ID: <20070315.002516.59485075.davem@davemloft.net>
References: <20070312210907.509184287@linux-foundation.org>
	<20070315021840.GG1246@kvack.org>
	<45F8E793.7040603@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bcrl@kvack.org, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43044
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932478AbXCOHZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2007 03:25:18 -0400
In-Reply-To: <45F8E793.7040603@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 15 Mar 2007 07:28:35 +0100

> One problem with your patch is that all read_always() of pointers are going to 
> use 3 bytes more of code, thus raising icache pressure.
> 
> 48 b8 c3 08 e8 8c af    mov    $0x71af8ce808c3,%rax
> 71 00 00
> 
> instead of %rip relative addressing
> 
> 48 8b 05 99 f3 09 00    mov    652185(%rip),%rax

Could we obtain %rip relative addressing with the ELF
relocation approach I mentioned?
