From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] Prefix List patch against 2.5.70
Date: Wed, 18 Jun 2003 05:59:59 +0900 (JST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030618.055959.55006678.yoshfuji@linux-ipv6.org>
References: <20030531.110249.12960077.yoshfuji@linux-ipv6.org>
	<20030530.233257.21920899.davem@redhat.com>
	<3EEF7E09.8080608@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: krkumar@us.ibm.com
In-Reply-To: <3EEF7E09.8080608@us.ibm.com>
List-Id: netdev.vger.kernel.org

In article <3EEF7E09.8080608@us.ibm.com> (at Tue, 17 Jun 2003 13:46:01 -0700), Krishna Kumar <krkumar@us.ibm.com> says:

> I have a question about the following, which seems to be the
> approach both of you prefer. I thought we need a new routing
> message type called RTM_GETPLIST which will return full prefix
> list. If you use RTA_RA6INFO, then should that trigger only
> when the prefix list has changed (add or delete) ? Should I
> have both interfaces, one for returning entire list (RTM) and
> one for changes in prefix list (RTA) ?
> 
> Please let me know if my understanding is correct.

Well, I think the problem is to set RTF_ADDRCONF flag to all prefix routes.
I beleive this should be for autoconf (RA) routes only as comments says;
dad_starts and multicast add routes with such flag, but this should be wrong.
After we fix this, we can get prefix information filtering routes by 
RTF_ADDRCONF flag; of course, we can get the routes using RTM_GETROUTE.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
