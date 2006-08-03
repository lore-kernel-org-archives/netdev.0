From: David Miller <davem@davemloft.net>
Subject: Re: Bug in IPSEC?
Date: Thu, 03 Aug 2006 16:26:36 -0700 (PDT)
Message-ID: <20060803.162636.31753120.davem@davemloft.net>
References: <34d8b2fe0608020808r7539ccc9h3f9a0beb5819d0a0@mail.gmail.com>
	<20060803011959.GB4958@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: louis.croisez@gmail.com, netdev@vger.kernel.org, jmorris@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:33453
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751386AbWHCX0e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 19:26:34 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060803011959.GB4958@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 3 Aug 2006 11:19:59 +1000

> (To recap our sha256 IPsec implementation truncates the output to 96
> bits while the last IETF draft on sha256 and the general HMAC RFC
> requires 128 bits)
> 
> Yes I agree with your assessment.
> 
> Changing it is nasty though since we don't know how many Linux users
> have deployed this.
> 
> Also, we should keep in mind that the IETF has given up on sha256
> altogether.

I think we have to leave things as is by default, and find some
way to provide a 128-bits mode that can be selected by the user.
