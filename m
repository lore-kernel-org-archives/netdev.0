From: David Miller <davem@davemloft.net>
Subject: Re: [patch] cxgb4: silence shift wrapping static checker warning
Date: Mon, 13 Jan 2014 11:16:39 -0800 (PST)
Message-ID: <20140113.111639.277633933727182124.davem@davemloft.net>
References: <20140109053400.GF1265@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dm@chelsio.com, kumaras@chelsio.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37972 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632AbaAMTQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 14:16:40 -0500
In-Reply-To: <20140109053400.GF1265@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 9 Jan 2014 08:34:00 +0300

> I don't know how large "tp->vlan_shift" is but static checkers worry
> about shift wrapping bugs here.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied to 'net'.

I don't think I'll be able to get this into 3.13, but on the off chance
Linus has to do another -rc I'll try to send it to him.
