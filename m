From: KOVACS Krisztian <hidden@balabit.hu>
Subject: Re: RFC: XFRM changing the view of xfrm_aevent_id
Date: Fri, 1 Dec 2006 15:47:56 +0100
Message-ID: <200612011547.57684@nienna>
References: <1164983872.3562.45.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:39435 "EHLO lists.balabit.hu")
	by vger.kernel.org with ESMTP id S936515AbWLAOsM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Dec 2006 09:48:12 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 384D14C03C
	for <netdev@vger.kernel.org>; Fri,  1 Dec 2006 15:48:10 +0100 (CET)
To: hadi@cyberus.ca
In-Reply-To: <1164983872.3562.45.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


  Hi,

On Friday 01 December 2006 15:37, jamal wrote:
> struct xfrm_aevent_id {
>         struct xfrm_usersa_id           sa_id;
>         __u32                           flags;
> };
>
> I could add the two items mentioned above in it and break the ABI.
> This may sound dangerous, but the usage of this ABI is not widespread.
> AFAIK, the only other person who might have used this is Kristzian (on
> CC).

  I do not use the XFRM netlink interface at the moment, so breaking the 
ABI is absolutely not a problem for me.

--
 Regards,
  Krisztian Kovacs
