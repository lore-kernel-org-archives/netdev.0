From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: tun: release the reference of tun device in
 tun_recvmsg
Date: Mon, 29 Apr 2013 11:07:07 -0400 (EDT)
Message-ID: <20130429.110707.1863217645953788370.davem@davemloft.net>
References: <201304250822.38944.a.miskiewicz@gmail.com>
	<1366876763-2671-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: a.miskiewicz@gmail.com, netdev@vger.kernel.org, jasowang@redhat.com
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56972 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751496Ab3D2PHN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 11:07:13 -0400
In-Reply-To: <1366876763-2671-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Thu, 25 Apr 2013 15:59:23 +0800

> We forget to release the reference of tun device in tun_recvmsg.
> bug introduced in commit 54f968d6efdbf7dec36faa44fc11f01b0e4d1990
> (tuntap: move socket to tun_file)
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>

Applied, and queued up for -stable, thanks.
