From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [DCCP] [RFC]: Getting rid of unwieldy struct prefixes
Date: Fri, 29 Feb 2008 11:23:34 -0300
Message-ID: <20080229142334.GL4306@ghostprotocols.net>
References: <20080229094518.GA12858@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>, Arnaldo <acme@redhat.com>,
	dccp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51238 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756771AbYB2OYm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 09:24:42 -0500
Content-Disposition: inline
In-Reply-To: <20080229094518.GA12858@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Fri, Feb 29, 2008 at 09:45:18AM +0000, Gerrit Renker escreveu:
> [CCID-2]: Get rid of ccid2hc{tx,rx}_ prefixes
> 
> Following discussion with Leandro yesterday, this is a  request-for-comments
> patch to fix two problems caused by the ubiquitous long "hctx->ccid2htx_" and
> "hcrx->ccid2hcrx_" prefixes:
>  -> code becomes hard to read;
>  -> multiple-line statements are almost inevitable even for simple expressions;
>  -> the prefixes are not really necessary - compare with "struct tcp_sock".

I haven't checked, is this over what is now on the test tree or on
upstream?

- Arnaldo
