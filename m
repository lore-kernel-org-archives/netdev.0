From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Tue, 28 Sep 2010 07:37:47 +0200
Message-ID: <20100928053747.GF12373@1wt.eu>
References: <20100927192112.GT12373@1wt.eu> <20100927232857.GA23803@gondor.apana.org.au> <20100928051258.GB12373@1wt.eu> <20100927.223231.179927955.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.hengli.com.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:45756 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752998Ab0I1Fhx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Sep 2010 01:37:53 -0400
Content-Disposition: inline
In-Reply-To: <20100927.223231.179927955.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 27, 2010 at 10:32:31PM -0700, David Miller wrote:
> From: Willy Tarreau <w@1wt.eu>
> Date: Tue, 28 Sep 2010 07:12:58 +0200
> 
> > Once again, for now, I will only handle this precise case of the extra
> > CRLF, but this will not fix the issue with pipelined requests.
> 
> You might want to read server/connection.c in the apache httpd
> sources.
>
> It does exactly what Eric Dumazet and I have suggested to you.

I've seen that. Though nginx, squid, thttpd, haproxy and lighttpd all
make use of the standard orphans and are all affected by the same issue.

> But, I guess the entire world is wrong and you're right Willy.

Given the figures above, that's not how I analyze it, I'm sorry.

Willy

