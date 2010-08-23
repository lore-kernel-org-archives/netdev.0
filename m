From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: add 64bit support to ifstat
Date: Mon, 23 Aug 2010 13:06:30 -0700
Message-ID: <20100823130630.1dcb885b@nehalam>
References: <20100823083258.0777e83d@nehalam>
	<1282578203.2267.27.camel@achroite.uk.solarflarecom.com>
	<20100823091750.2bf87605@nehalam>
	<1282582464.2486.479.camel@edumazet-laptop>
	<20100823103333.67c5f795@nehalam>
	<1282592696.2378.193.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39524 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753621Ab0HWUGc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Aug 2010 16:06:32 -0400
In-Reply-To: <1282592696.2378.193.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> @@ -563,8 +563,6 @@ static void usage(void)
>  "   -s, --noupdate	don;t update history\n"
>  "   -t, --interval=SECS	report average over the last SECS\n"
>  "   -V, --version	output version information\n"
> -"   -z, --zeros		show entries with zero activity\n"
> -"   -e, --errors	show errors\n"
>  "   -z, --zeros		show entries with zero activity\n");
>  
>  	exit(-1);
> @@ -581,8 +579,6 @@ static const struct option longopts[] = {
>  	{ "interval", 1, 0, 't' },
>  	{ "version", 0, 0, 'V' },
>  	{ "zeros", 0, 0, 'z' },
> -	{ "errors", 0, 0, 'e' },
> -	{ "zeros", 0, 0, 'z' },
>  	{ 0 }
>  };
>  
> 
> 

Did you mean to break --errors?
