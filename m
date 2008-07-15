From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/7 net-next-2.6] tipc: Add missing locks when
 inspecting node list & link list
Date: Mon, 14 Jul 2008 22:45:05 -0700 (PDT)
Message-ID: <20080714.224505.168732920.davem@davemloft.net>
References: <1215725171-10094-1-git-send-email-allan.stephens@windriver.com>
	<1215725171-10094-7-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60019
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755481AbYGOFpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 01:45:04 -0400
In-Reply-To: <1215725171-10094-7-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Thu, 10 Jul 2008 17:26:10 -0400

> This patch ensures that TIPC configuration commands that display info
> about neighboring nodes and their links take the spinlocks that
> protect the node list and link lists from changing while the lists
> are being traversed.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

Applied.
