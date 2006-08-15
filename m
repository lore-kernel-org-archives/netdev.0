From: David Miller <davem@davemloft.net>
Subject: Re: Possible leak of multicast source filter sctructure
Date: Tue, 15 Aug 2006 00:21:39 -0700 (PDT)
Message-ID: <20060815.002139.107685177.davem@davemloft.net>
References: <20060813.204405.28205494.davem@davemloft.net>
	<OF76CDD1A8.A722B591-ON882571CA.00781509-882571CA.007980C0@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, michal.ruzicka@comstar.cz,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:32680
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965271AbWHOHVi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 03:21:38 -0400
To: dlstevens@us.ibm.com
In-Reply-To: <OF76CDD1A8.A722B591-ON882571CA.00781509-882571CA.007980C0@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Stevens <dlstevens@us.ibm.com>
Date: Mon, 14 Aug 2006 15:07:08 -0700

>         The first patch in that, yes.
> 
> Acked-by: David L Stevens <dlstevens@us.ibm.com>

I've applied it and will push to net-2.6.18

>         I'm not sure the second one is quite right. The case of concern
> is where an interface is deleted. If you joined (or left) the group by
> address and then deleted the interface, then you wouldn't match the
> index (which wouldn't be set) so the leave wouldn't work, still.
>         Also, if you passed a completely bogus ifindex, it should return
> ENODEV, but with the patch it would return EADDRNOTAVAIL it appears.
>         So, I think the second patch needs some more work. I'll look at
> it some more and see if I can suggest something better.

Ok, this second patch does need to be refined a little bit.
