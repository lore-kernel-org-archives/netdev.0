From: David Miller <davem@davemloft.net>
Subject: Re: IPsecv6 tunnel mode fragmentation
Date: Wed, 08 Dec 2010 12:37:59 -0800 (PST)
Message-ID: <20101208.123759.116371401.davem@davemloft.net>
References: <1291587520.11224.38.camel@faith.austin.ibm.com>
	<20101208071109.GA14537@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: latten@austin.ibm.com, netdev@vger.kernel.org,
	samudrala@us.ibm.com, rashmin@us.ibm.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34023
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756576Ab0LHUhb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 15:37:31 -0500
In-Reply-To: <20101208071109.GA14537@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 8 Dec 2010 15:11:09 +0800

> Joy Latten <latten@austin.ibm.com> wrote:
>> 
>> We have come across an ipsec problem that I think was
>> noted a while back in the following link.
>> http://www.mail-archive.com/netdev@vger.kernel.org/msg61659.html
> 
> Looks like a configuration issue to me.  One end is using the
> same IP address (*::1234) both within and outside the tunnel.
> Thus when the ICMP error message is sent it ends up outside the
> tunnel causing it to be discarded by the other side.
> 
> So if you're using tunnel mode you really should use distinct
> IP addresses.

Agreed.
