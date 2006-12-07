From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] convert hh_lock to seqlock
Date: Thu, 07 Dec 2006 15:08:42 -0800 (PST)
Message-ID: <20061207.150842.130237483.davem@davemloft.net>
References: <20061207113309.2f892cf1@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33072
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1163727AbWLGXIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 18:08:39 -0500
To: shemminger@osdl.org
In-Reply-To: <20061207113309.2f892cf1@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Thu, 7 Dec 2006 11:33:09 -0800

> The hard header cache is in the main output path, so using
> seqlock instead of reader/writer lock should reduce overhead.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

I've applied this, thanks Stephen.
