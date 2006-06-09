From: David Miller <davem@davemloft.net>
Subject: Re: [patch 8/9] secmark: Add CONNSECMARK xtables target
Date: Fri, 09 Jun 2006 00:32:52 -0700 (PDT)
Message-ID: <20060609.003252.99204683.davem@davemloft.net>
References: <200606090520.k595KwnD032104@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:11672
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751415AbWFIHdh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jun 2006 03:33:37 -0400
To: akpm@osdl.org
In-Reply-To: <200606090520.k595KwnD032104@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Thu, 08 Jun 2006 22:20:58 -0700

> Add a new xtables target, CONNSECMARK, which is used to specify rules for
> copying security marks from packets to connections, and for copyying security
> marks back from connections to packets.  This is similar to the CONNMARK
> target, but is more limited in scope in that it only allows copying of
> security marks to and from packets, as this is all it needs to do.
> 
> A typical scenario would be to apply a security mark to a 'new' packet with
> SECMARK, then copy that to its conntrack via CONNMARK, and then restore the
> security mark from the connection to established and related packets on that
> connection.
> 
> Signed-off-by: James Morris <jmorris@namei.org>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied to net-2.6.18, thanks.
