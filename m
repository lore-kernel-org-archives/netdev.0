From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7][BNX2]: Remove REG_WR_IND/REG_RD_IND macros.
Date: Tue, 29 Jan 2008 21:35:15 -0800 (PST)
Message-ID: <20080129.213515.125486015.davem@davemloft.net>
References: <1201652373.19087.12.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56872
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754150AbYA3Fe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 00:34:56 -0500
In-Reply-To: <1201652373.19087.12.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 29 Jan 2008 16:19:33 -0800

> [BNX2]: Remove REG_WR_IND/REG_RD_IND macros.
> 
> The REG_WR_IND/REG_RD_IND macros are unnecessary and obfuscate the
> code.  Many callers to these macros read and write shared memory from
> the bp->shmem_base, so we add 2 similar functions that automatically
> add the shared memory base.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Nice cleanup, applied.
