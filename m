From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cleanup of the sctp state table code
Date: Mon, 13 Nov 2006 16:18:33 -0800 (PST)
Message-ID: <20061113.161833.70217638.davem@davemloft.net>
References: <1163425085.5968.29.camel@twins>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:38585
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S933234AbWKNASY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Nov 2006 19:18:24 -0500
To: a.p.zijlstra@chello.nl
In-Reply-To: <1163425085.5968.29.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon, 13 Nov 2006 14:38:05 +0100

> I noticed an insane high density of repeated characters fixable by a
> simple regular expression:
> 
>   % s/{.fn = \([^,]*\),[[:space:]]\+\(\\\n[[:space:]]\+\)\?.name = "\1"}/TYPE_SCTP_FUNC(\1)/g
> 
> (NOTE: the .name for .fn = sctp_sf_do_9_2_start_shutdown didn't match)
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

I'll apply this to net-2.6.20, thanks Peter.

If the SCTP maintainers have some objection, I'll yank it out
but I can't see why they would :-)
