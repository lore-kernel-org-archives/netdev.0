From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: ax25: fix information leak to userland
Date: Wed, 10 Nov 2010 10:14:49 -0800 (PST)
Message-ID: <20101110.101449.104041941.davem@davemloft.net>
References: <1289412757-11411-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, jreuter@yaina.de,
	ralf@linux-mips.org, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: segooon@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56994
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754871Ab0KJSOZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 13:14:25 -0500
In-Reply-To: <1289412757-11411-1-git-send-email-segooon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasiliy Kulikov <segooon@gmail.com>
Date: Wed, 10 Nov 2010 21:12:36 +0300

> Sometimes ax25_getname() doesn't initialize all members of fsa_digipeater
> field of fsa struct, also the struct has padding bytes between
> sax25_call and sax25_ndigis fields.  This structure is then copied to
> userland.  It leads to leaking of contents of kernel stack memory.
> 
> Signed-off-by: Vasiliy Kulikov <segooon@gmail.com>

Looks good to me, applied.

Thanks!
