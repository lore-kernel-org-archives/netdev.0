From: Wang Jian <lark@linux.net.cn>
Subject: Re: drivers/net/phy/marvell.c: 88e1111 can't get out sleep mode
Date: Thu, 02 Oct 2008 18:10:48 +0800
Message-ID: <48E49E28.6050500@linux.net.cn>
References: <20080929133305.GA10554@debian> <2acbd3e40809291314t41b6f765k9aa7809ca21bd88d@mail.gmail.com> <48E2175F.1000306@linux.net.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>,
	Alexandr Smirnov <asmirnov@ru.mvista.com>
To: Andy Fleming <afleming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [210.82.31.146] ([210.82.31.146]:58132 "EHLO mx.linux.net.cn"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752794AbYJBKKt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2008 06:10:49 -0400
In-Reply-To: <48E2175F.1000306@linux.net.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Jian wrote:
> I have an idea that if the phy is in sleep mode, flip flop energy detect 
> mode to
> leave sleep mode. This is done every 6 seconds, not so intrusive. I will 
> try it
> later.
> 

No success so far.

MII_PDOWN then MII_RESET no success either.
