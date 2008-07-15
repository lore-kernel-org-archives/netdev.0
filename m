From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/7 net-next-2.6] tipc: Eliminate improper use of
 TIPC_OK error code
Date: Mon, 14 Jul 2008 22:44:08 -0700 (PDT)
Message-ID: <20080714.224408.03462805.davem@davemloft.net>
References: <1215725171-10094-1-git-send-email-allan.stephens@windriver.com>
	<1215725171-10094-5-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60013
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754890AbYGOFoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 01:44:08 -0400
In-Reply-To: <1215725171-10094-5-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Thu, 10 Jul 2008 17:26:08 -0400

> This patch corrects many places where TIPC routines indicated
> successful completion by returning TIPC_OK instead of 0.
> (The TIPC_OK symbol has the value 0, but it should only be used
> in contexts that deal with the error code field of a TIPC
> message header.)
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

Applied.
