From: David Miller <davem@davemloft.net>
Subject: Re: ppp, "Features changed" flooding the log
Date: Fri, 20 May 2011 14:22:22 -0400 (EDT)
Message-ID: <20110520.142222.237998533879021225.davem@davemloft.net>
References: <a08c037f093701d9a2d187d04ac85fee@visp.net.lb>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: denys@visp.net.lb
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58485 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934989Ab1ETSW1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2011 14:22:27 -0400
In-Reply-To: <a08c037f093701d9a2d187d04ac85fee@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denys Fedoryshchenko <denys@visp.net.lb>
Date: Fri, 20 May 2011 16:42:08 +0300

> Hi
> 
> Is it supposed to be like this?
> [   41.575487] ppp313: Features changed: 0x00006800 -> 0x00006000
> [   41.681499] ppp314: Features changed: 0x00006800 -> 0x00006000
> [   41.796728] ppp315: Features changed: 0x00006800 -> 0x00006000
> [   41.909575] ppp316: Features changed: 0x00006800 -> 0x00006000
> [   42.027802] ppp317: Features changed: 0x00006800 -> 0x00006000
> [   42.142698] ppp318: Features changed: 0x00006800 -> 0x00006000
> [   42.292753] ppp319: Features changed: 0x00006800 -> 0x00006000
> [   42.408706] ppp320: Features changed: 0x00006800 -> 0x00006000
> [   42.544745] ppp321: Features changed: 0x00006800 -> 0x00006000
> [   42.634743] ppp322: Features changed: 0x00006800 -> 0x00006000
> [   42.740747] ppp323: Features changed: 0x00006800 -> 0x00006000
> [   42.856579] ppp324: Features changed: 0x00006800 -> 0x00006000
> 
> I guess ppp dropping GSO, but is it should be there on first place?
> GSO is disabled on all ethernet interfaces.

Linus released 2.6.39 before I could merge the patch that gets rid
of this, will send it to 2.6.39-stable.
