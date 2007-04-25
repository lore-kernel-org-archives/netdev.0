From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.20.7 mss negotiation and path mtu discovery mostly broken?
Date: Thu, 26 Apr 2007 08:48:23 +1000
Message-ID: <E1HgqHf-0003xF-00@gondolin.me.apana.org.au>
References: <7CCD07160348804497EF29E9EA5560D7020F6212@exchtewks2.starentnetworks.com>
Cc: netdev@vger.kernel.org
To: bristuccia@starentnetworks.com (Ristuccia, Brian)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1150 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1423395AbXDYWsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 18:48:38 -0400
In-Reply-To: <7CCD07160348804497EF29E9EA5560D7020F6212@exchtewks2.starentnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ristuccia, Brian <bristuccia@starentnetworks.com> wrote:
> 
> 08:39:55.649689 IP 10.2.10.254.22 > 12.33.234.69.35026: .
> 5906:10250(4344) ack 1
> 794 win 674 <nop,nop,timestamp 413790 3873837887>
> 08:39:55.650532 IP 10.2.10.1 > 10.2.10.254: icmp 92: 12.33.234.69
> unreachable -
> need to frag (mtu 1500)

Where was this dump taken, on 10.2.10.254?

If so could youd either take the dump further down the route or show
the full contents (with tcpdump -x) of the ICMP error here so that
we can see what the actual packet size was?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
