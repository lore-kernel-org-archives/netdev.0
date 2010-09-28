From: David Miller <davem@davemloft.net>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Mon, 27 Sep 2010 22:32:31 -0700 (PDT)
Message-ID: <20100927.223231.179927955.davem@davemloft.net>
References: <20100927192112.GT12373@1wt.eu>
	<20100927232857.GA23803@gondor.apana.org.au>
	<20100928051258.GB12373@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, netdev@vger.kernel.org
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36190
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755814Ab0I1FcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 01:32:11 -0400
In-Reply-To: <20100928051258.GB12373@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Tue, 28 Sep 2010 07:12:58 +0200

> Once again, for now, I will only handle this precise case of the extra
> CRLF, but this will not fix the issue with pipelined requests.

You might want to read server/connection.c in the apache httpd
sources.

It does exactly what Eric Dumazet and I have suggested to you.

But, I guess the entire world is wrong and you're right Willy.
