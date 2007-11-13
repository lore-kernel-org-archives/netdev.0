From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: 2.6.24-rc2: Network commit causes SLUB performance regression with tbench
Date: Wed, 14 Nov 2007 09:55:03 +1100
Message-ID: <200711140955.03989.nickpiggin@yahoo.com.au>
References: <200711140436.24492.nickpiggin@yahoo.com.au> <20071113.223726.40898879.davem@davemloft.net> <200711140927.39796.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: clameter@sgi.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp103.mail.mud.yahoo.com ([209.191.85.213]:43455 "HELO
	smtp103.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752217AbXKNLDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 06:03:06 -0500
In-Reply-To: <200711140927.39796.nickpiggin@yahoo.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 14 November 2007 09:27, Nick Piggin wrote:

> > 2) Try removing NETIF_F_SG in drivers/net/loopback.c's dev->feastures
> >    setting.
>
> Will try that now.

Doesn't help (with vanilla kernel -- Herbert's patch applied).

data_len histogram drops to 0 and goes to len (I guess that's not
surprising).

Performance is pretty similar (ie. not good).

I'll look at allocator patterns next.
