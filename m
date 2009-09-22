From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] drivers/net: remove duplicate structure field
 initialization
Date: Tue, 22 Sep 2009 14:21:15 -0700 (PDT)
Message-ID: <20090922.142115.139068968.davem@davemloft.net>
References: <Pine.LNX.4.64.0909192148180.27171@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753272AbZIVVU6@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0909192148180.27171@ask.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>
Date: Sat, 19 Sep 2009 21:48:41 +0200 (CEST)

> From: Julia Lawall <julia@diku.dk>
> 
> The definitions of vnet_ops and ehea_netdev_ops have initializations of a
> local function and eth_change_mtu for their respective ndo_change_mtu
> fields.  This change uses only the local function.
> 
> The semantic match that finds this problem is as follows:
> (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied.
