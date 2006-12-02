From: David Miller <davem@davemloft.net>
Subject: Re: RFC: XFRM changing the view of xfrm_aevent_id
Date: Fri, 01 Dec 2006 20:08:58 -0800 (PST)
Message-ID: <20061201.200858.25157271.davem@davemloft.net>
References: <1164983872.3562.45.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hidden@balabit.hu, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:4529
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1162451AbWLBEIv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Dec 2006 23:08:51 -0500
To: hadi@cyberus.ca
In-Reply-To: <1164983872.3562.45.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Fri, 01 Dec 2006 09:37:52 -0500

> The structure currently looks like
> 
> struct xfrm_aevent_id {
>         struct xfrm_usersa_id           sa_id;
>         __u32                           flags;
> };
> 
> I could add the two items mentioned above in it and break the ABI.
> This may sound dangerous, but the usage of this ABI is not widespread.
> AFAIK, the only other person who might have used this is Kristzian (on
> CC).
> 
> If this is considered evil, then i will transfer the two items in
> a new TLV but it wont be as pretty.
> 
> Thoughts?

Let's change it now while we still can.

A few months from now, I will probably not give the same
answer :)
