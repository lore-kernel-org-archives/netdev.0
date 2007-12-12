From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/8][BNX2]: Restructure RX ring init. code.
Date: Wed, 12 Dec 2007 11:17:55 -0800 (PST)
Message-ID: <20071212.111755.61152229.davem@davemloft.net>
References: <1197485945.16386.28.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55926
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760131AbXLLTR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 14:17:56 -0500
In-Reply-To: <1197485945.16386.28.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 12 Dec 2007 10:59:05 -0800

> [BNX2]: Restructure RX ring init. code.
> 
> Factor out the common functions that will be used to initialize the
> normal RX rings and the page rings.
> 
> Change the copybreak constant RX_COPY_THRESH to 128.  This same
> constant will be used for the max. size of the linear SKB when pages
> are used.  Copybreak will be turned off when pages are used.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
