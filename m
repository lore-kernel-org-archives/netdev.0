From: Patrick McHardy <kaber@trash.net>
Subject: Re: another critical bug ?
Date: Thu, 29 Mar 2007 12:58:37 +0200
Message-ID: <460B9BDD.1020307@trash.net>
References: <20070321175951.M73913@visp.net.lb>	<46026717.9060909@trash.net>	<20070322124533.M79867@visp.net.lb>	<46027FF2.6020001@trash.net> <20070322101224.3e6bb899@freekitty> <4602B96A.5000308@trash.net> <20070326182654.M24011@visp.net.lb> <460933EC.9060908@trash.net> <20070327155922.M1237@visp.net.lb> <46094472.1050807@trash.net> <20070328235517.M35794@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Denys <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40954 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030221AbXC2KwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2007 06:52:16 -0400
In-Reply-To: <20070328235517.M35794@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denys wrote:
> Tried on 2.6.21-rc5-git3, but preempt enabled
> Same panic, same place seems
> 
> Mar 29 02:50:53 LINUX [  164.644102] BUG: unable to handle kernel paging 
> request
> Mar 29 02:50:53 LINUX at virtual address 0302014c

> Mar 29 02:50:53 LINUX [  164.648948] EIP is at netif_rx+0x12/0x115
>[...]
> Mar 29 02:50:53 LINUX [  164.650829]  [<c8a1f268>]
> Mar 29 02:50:53 LINUX ri_tasklet+0xd5/0x1a1 [ifb]


Its somehow related to ifb. Please send your .config and the commands
you use to setup ifb.
