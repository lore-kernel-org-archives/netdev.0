From: David Miller <davem@davemloft.net>
Subject: Re: ucc_geth: Fix the wrong the Rx/Tx FIFO size
Date: Wed, 06 Jan 2010 20:32:50 -0800 (PST)
Message-ID: <20100106.203250.80870186.davem@davemloft.net>
References: <1262597823-13788-1-git-send-email-daveliu@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: daveliu@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59120
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756412Ab0AGEcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 23:32:43 -0500
In-Reply-To: <1262597823-13788-1-git-send-email-daveliu@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Liu <daveliu@freescale.com>
Date: Mon,  4 Jan 2010 17:37:03 +0800

> current the Rx/Tx FIFO size settings cause problem
> when four UEC ethernets work simultaneously.
> 
> eg: GETH1, UEM-J15, GETH2, UEC-J5 on 8569MDS board
> 
>  $ ifconfig eth0 10.193.20.166
>  $ ifconfig eth1 10.193.20.167
>  $ ifconfig eth2 10.193.20.168
>  then
>  $ ifconfig eth3 10.193.20.169
> 
> The fourth ethernet will cause all of interface broken,
> you cann't ping successfully any more.
> The patch fix this issue for MPC8569 Rev1.0 and Rev2.0
> 
> Signed-off-by: Dave Liu <daveliu@freescale.com>
> Acked-by: Anton Vorontsov <avorontsov@ru.mvista.com>

Applied to net-2.6, thank you.
