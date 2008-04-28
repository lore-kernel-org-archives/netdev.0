From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: TCP slowdown in 2.6.25?
Date: Mon, 28 Apr 2008 15:33:06 +0200
Message-ID: <1209389586.6904.17.camel@gentoo-jocke.transmode.se>
References: <1209384733.6904.12.camel@gentoo-jocke.transmode.se>
Reply-To: joakim.tjernlund@transmode.se
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:42437 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1762368AbYD1NdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 09:33:08 -0400
In-Reply-To: <1209384733.6904.12.camel@gentoo-jocke.transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2008-04-28 at 14:12 +0200, Joakim Tjernlund wrote:
> After upgrading from 2.6.23 to 2.6.25 I am seeing a big slow down on
> our old www server. Stracing shows lots of EAGAIN but i not sure
> these are relevant. I got no idea where to start looking so
> I would appreciate some pointers. Perhaps this is a know issue?
> 
> CPU is a PowerPC, mpc8321, network driver ucc_geth
> 
>  Jocke

Some info:
Even ftp transfers takes forever, but only in one direction: from the
node with kernel 2.6.25 to some other host. Strace show me that
write(2) hangs for long periods before succeeding to transmit 
the data.
