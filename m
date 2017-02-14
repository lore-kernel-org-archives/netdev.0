From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] net: fec: fix multicast filtering hardware
 setup
Date: Tue, 14 Feb 2017 12:15:53 -0500 (EST)
Message-ID: <20170214.121553.2045090305512818190.davem@davemloft.net>
References: <1486951285-30668-1-git-send-email-fugang.duan@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, festevam@gmail.com,
        stephen@networkplumber.org
To: fugang.duan@nxp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37048 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753176AbdBNRPz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 12:15:55 -0500
In-Reply-To: <1486951285-30668-1-git-send-email-fugang.duan@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Duan <fugang.duan@nxp.com>
Date: Mon, 13 Feb 2017 10:01:25 +0800

> From: Rui Sousa <rui.sousa@nxp.com>
> 
> Fix hardware setup of multicast address hash:
> - Never clear the hardware hash (to avoid packet loss)
> - Construct the hash register values in software and then write once
> to hardware
> 
> Signed-off-by: Rui Sousa <rui.sousa@nxp.com>
> Signed-off-by: Fugang Duan <fugang.duan@nxp.com>

Applied, thanks.
