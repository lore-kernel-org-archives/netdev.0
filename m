From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 0/4][RFC]: coding convention for CCID-struct prefixes
Date: Mon, 5 Oct 2009 09:38:23 -0300
Message-ID: <20091005123823.GE30535@ghostprotocols.net>
References: <1254739993-5051-1-git-send-email-gerrit@erg.abdn.ac.uk> <20091005.035815.238234647.davem@davemloft.net> <20091005112359.GB5156@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	David Miller <davem@davemloft.net>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15989 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753989AbZJEMjE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Oct 2009 08:39:04 -0400
Content-Disposition: inline
In-Reply-To: <20091005112359.GB5156@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Mon, Oct 05, 2009 at 01:23:59PM +0200, Gerrit Renker escreveu:
> | After Arnaldo takes a look, I can add this as-is to net-next-2.6
> This should work, they have been compile/sparse-tested and apply cleanly on net-2.6.
> 
> I am waiting for the feedback also in order to rebuild the test tree; and have
> informed CCID-4 developers (CCID-4 subtree) about this.

On a first look I saw one inconsistency, while in ccid3 you do:

-	return scaled_div(w_init << 6, hctx->tx_rtt);
+	return scaled_div(w_init << 6, hc->tx_rtt);

in ccid2 you do:

-	struct ccid2_seq *seqp = hctx->ccid2hctx_seqh;
+	struct ccid2_seq *seqp = hctx->tx_seqh;

Since this change is about reducing the names by removing redundancy, I
think the ccid3 variant is better, i.e.: hc->tx_foo.

- Arnaldo
