From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 5/11][TR] Use ctl paths to register
 net/token-ring/ table
Date: Wed, 05 Dec 2007 01:42:23 -0800 (PST)
Message-ID: <20071205.014223.28290437.davem@davemloft.net>
References: <4755256F.9000505@openvz.org>
	<47552744.50609@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35290
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751833AbXLEJmZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 04:42:25 -0500
In-Reply-To: <47552744.50609@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 04 Dec 2007 13:09:08 +0300

> The same thing for token-ring - use ctl paths and get
> rid of external references on the tr_table.
> 
> Unfortunately, I couldn't split this patch into cleanup and 
> use-the-paths parts.
> 
> As a lame excuse I can say, that the cleanup is just moving
> the tr_table from one file to another - closet to a single
> variable, that this ctl table tunes. Since the source  file 
> becomes empty after the move, I remove it.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
