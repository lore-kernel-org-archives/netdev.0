From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [V3] net: ipconfig: avoid warning by making
 ic_addrservaddr static
Date: Fri, 10 Jun 2016 23:28:27 -0700 (PDT)
Message-ID: <20160610.232827.2140942752793209041.davem@davemloft.net>
References: <1465557066-3968-1-git-send-email-ben.dooks@codethink.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org
To: ben.dooks@codethink.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35225 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbcFKG23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 02:28:29 -0400
In-Reply-To: <1465557066-3968-1-git-send-email-ben.dooks@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Dooks <ben.dooks@codethink.co.uk>
Date: Fri, 10 Jun 2016 12:11:06 +0100

> The symbol ic_addrservaddr is not static, but has no declaration
> to match so make it static to fix the following warning:
> 
> net/ipv4/ipconfig.c:130:8: warning: symbol 'ic_addrservaddr' was not declared. Should it be static?
> 
> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>

Applied.
