From: David Miller <davem@davemloft.net>
Subject: Re: [patch 14/28] dccp: fix memory leak and clean up style -
 dccp_feat_empty_confirm()
Date: Fri, 10 Aug 2007 15:24:09 -0700 (PDT)
Message-ID: <20070810.152409.69410107.davem@davemloft.net>
References: <200708102111.l7ALBwC1009414@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesper.juhl@gmail.com,
	ian.mcdonald@jandi.co.nz
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52978
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756317AbXHJWYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 18:24:09 -0400
In-Reply-To: <200708102111.l7ALBwC1009414@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Fri, 10 Aug 2007 14:11:57 -0700

> From: Jesper Juhl <jesper.juhl@gmail.com>
> 
> There's a memory leak in net/dccp/feat.c::dccp_feat_empty_confirm().  If we
> hit the 'default:' case of the 'switch' statement, then we return without
> freeing 'opt', thus leaking 'struct dccp_opt_pend' bytes.
> 
> The leak is fixed easily enough by adding a kfree(opt); before the return
> statement.
> 
> The patch also changes the layout of the 'switch' to be more in line with
> CodingStyle.
> 
> Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied to net-2.6, thanks!
