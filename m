From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: net-next-2.6 [PATCH 1/1] tcp: add missing initial window (RFC
	3390) for tcp_output
Date: Wed, 1 Sep 2010 12:16:50 +0200
Message-ID: <20100901101650.GA3455@gerrit.erg.abdn.ac.uk>
References: <1283145794-5615-1-git-send-email-gerrit@erg.abdn.ac.uk> <1283145794-5615-2-git-send-email-gerrit@erg.abdn.ac.uk> <1283145794-5615-3-git-send-email-gerrit@erg.abdn.ac.uk> <1283145794-5615-4-git-send-email-gerrit@erg.abdn.ac.uk> <alpine.DEB.2.00.1008301557590.31318@wel-95.cs.helsinki.fi> <20100901052355.GA5379@gerrit.erg.abdn.ac.uk> <20100901053443.GB5379@gerrit.erg.abdn.ac.uk> <428BF15F-19DC-459A-B54A-EC273ECF537E@comsys.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:62885 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752155Ab0IAKRJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Sep 2010 06:17:09 -0400
Content-Disposition: inline
In-Reply-To: <428BF15F-19DC-459A-B54A-EC273ECF537E@comsys.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

|  > --- a/net/ipv4/tcp_output.c
| > +++ b/net/ipv4/tcp_output.c
| > @@ -225,15 +225,11 @@ void tcp_select_initial_window(int __spa
| > 	}
| > 
| > 	/* Set initial window to value enough for senders,
| > -	 * following RFC2414. Senders, not following this RFC,
| > -	 * will be satisfied with 2.
| > +	 * following RFC5681 (which updates RFC3390).
| 
| In IETF sense, RFC5681 doesn't update RFC3390.
| 
RFC 3390 updates RFC 2581, and RFC 5681 replaces RFC 2581.
That was too long to write.

I will remove the comment.
