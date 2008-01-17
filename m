From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [RFC][PATCH] Fixing SA/SP dumps on netlink/af_key
Date: Thu, 17 Jan 2008 10:11:17 +0200
Message-ID: <478F0DA5.2060401@iki.fi>
References: <478EF542.1010702@iki.fi>	<20080116.231654.74131878.davem@davemloft.net>	<478F05E7.6070503@iki.fi> <20080116.235923.208347316.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, hadi@cyberus.ca,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:47110 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132AbYAQIKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 03:10:04 -0500
Received: by fg-out-1718.google.com with SMTP id e21so585089fga.17
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 00:10:03 -0800 (PST)
In-Reply-To: <20080116.235923.208347316.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> Doing anything other than "life support" bug fixes for AF_KEY is
> inappropriate.

Yes. I thought my patch would qualify as "life support" bug fix.
Currently racoon fails to work if there are too many SPDs or SAs
because the kernel cannot handle the dump request properly. And
this is what my patch fixes for pfkey. It adds no new features or
functionality; just makes the dumping work with large databases.

Then there's also the xfrm dumping changes which change the
algorithm from O(n^2) to O(n) with some memory overhead, but
that is a different story. Any comments on that?

- Timo
