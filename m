From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 1/2] netxen: fix race in tx stop queue
Date: Mon, 18 Oct 2010 07:23:29 -0700 (PDT)
Message-ID: <20101018.072329.226791224.davem@davemloft.net>
References: <1287403422-10431-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com, rajesh.borundia@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43899
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755345Ab0JROXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 10:23:07 -0400
In-Reply-To: <1287403422-10431-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Mon, 18 Oct 2010 05:03:41 -0700

> From: Rajesh Borundia <rajesh.borundia@qlogic.com>
> 
> There is race between netif_stop_queue and netif_stopped_queue
> check.So check once again if buffers are available to avoid race.
> With above logic we can also get rid of tx lock in process_cmd_ring.
> 
> Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

Applied.
