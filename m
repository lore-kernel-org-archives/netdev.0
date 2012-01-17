From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: BH already disabled in br_fdb_cleanup()
Date: Tue, 17 Jan 2012 10:17:48 -0500 (EST)
Message-ID: <20120117.101748.2208424129270763401.davem@davemloft.net>
References: <1326723932.2255.41.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1326724550.2255.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20120116075349.2e9bf1e1@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, steweg@gmail.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54535 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754306Ab2AQPRw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 10:17:52 -0500
In-Reply-To: <20120116075349.2e9bf1e1@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 16 Jan 2012 07:53:49 -0800

> On Mon, 16 Jan 2012 15:35:50 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
>> br_fdb_cleanup() is run from timer interrupt, BH already masked.
>> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
 ...
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.
