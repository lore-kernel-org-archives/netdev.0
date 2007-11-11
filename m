From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [PKT_SCHED] CLS_U32: Use ffs() instead of C code on
 hash mask to get first set bit.
Date: Sat, 10 Nov 2007 21:55:06 -0800 (PST)
Message-ID: <20071110.215506.214591476.davem@davemloft.net>
References: <1194520067-20868-1-git-send-email-radu.rendec@ines.ro>
	<1194529531.5743.9.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: radu.rendec@ines.ro, netdev@vger.kernel.org, jarkao2@o2.pl
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33082
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750711AbXKKFzH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2007 00:55:07 -0500
In-Reply-To: <1194529531.5743.9.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Thu, 08 Nov 2007 08:45:31 -0500

> On Thu, 2007-08-11 at 13:07 +0200, Radu Rendec wrote:
> > Computing the rank of the first set bit in the hash mask (for using later
> > in u32_hash_fold()) was done with plain C code. Using ffs() instead makes
> > the code more readable and improves performance (since ffs() is better
> > optimized in assembler).
> > 
> > Using the conditional operator on hash mask before applying ntohl() also
> > saves one ntohl() call if mask is 0.
> > 
> > Signed-off-by: Radu Rendec <radu.rendec@ines.ro>
> 
> Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>

Applied, thanks everyone.
