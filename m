From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] cxgb4: Fix namespace collision issue.
Date: Tue, 07 Jan 2014 15:48:13 -0500 (EST)
Message-ID: <20140107.154813.1483946457674959301.davem@davemloft.net>
References: <1389094088-6261-1-git-send-email-hariprasad@chelsio.com>
	<1389094088-6261-2-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dm@chelsio.com, leedom@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com, santosh@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44526 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753558AbaAGUsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 15:48:15 -0500
In-Reply-To: <1389094088-6261-2-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Tue,  7 Jan 2014 16:58:07 +0530

> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
  ...

> -int t4_init_tp_params(struct adapter *adap)

There is no reason that an already exported function must be moved
to solve a namespace issue.

If you want to move this function for another reason, fine, but do
it in a seperate change with a clear description of that reason in
your commit message.

I'm not applying this series.
