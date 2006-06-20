From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Network performance degradation from 2.6.11.12 to 2.6.16.20
Date: Tue, 20 Jun 2006 12:11:27 +1000
Message-ID: <E1FsViB-0006Qq-00@gondolin.me.apana.org.au>
References: <4496ACA6.7090305@atmos.washington.edu>
Cc: shemminger@osdl.org, akpm@osdl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:6404 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S964859AbWFTCLh
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jun 2006 22:11:37 -0400
To: harry@atmos.washington.edu (Harry Edmon)
In-Reply-To: <4496ACA6.7090305@atmos.washington.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Harry Edmon <harry@atmos.washington.edu> wrote:
> 
> That did not help.  I have 1 minute outputs from tcpdump under both 2.6.11.12 
> and 2.6.16.20.  You will see a large size difference between the files.  Since 
> the 2.6.11.12 one is 2 MBytes, I thought I would post them via the web instead 
> of via attachments.   Look at:
> 
> http://www.atmos.washington.edu/~harry/linux/2.6.11.12.out.1min
> http://www.atmos.washington.edu/~harry/linux/2.6.16.20.out.1min

The latter shows that it took 40ms to generate an ACK.  What does
'vmstat 1' show while this is happneing?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
