From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6 MIB:ipv6RouterAdvert netlink notification
Date: Fri, 16 Jan 2004 10:37:10 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040116.103710.94220850.yoshfuji@linux-ipv6.org>
References: <OFB4F51C5A.FC479F2C-ON87256E1C.007B64B8@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mashirle@us.ibm.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, xma@us.ibm.com
In-Reply-To: <OFB4F51C5A.FC479F2C-ON87256E1C.007B64B8@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <OFB4F51C5A.FC479F2C-ON87256E1C.007B64B8@us.ibm.com> (at Thu, 15 Jan 2004 14:31:47 -0800), Shirley Ma <xma@us.ibm.com> says:

> This patch is going to be used by SNMP for ipv6RouterAdvert Table. I will
> remove this Micro, and resubmit the patch.

This patch is conceptually wrong.

I think you're misunderstanding the darft.
ipv6RouterAdvertTable contains information used to create router
advertisements on router. Not on host.

Patch should be rejected.

>From draft-ietf-ipv6-rfc2011-update-05.txt:

--- cut here 
3.2.9.  Router Advertisement Table

This table contains the non-routing information that an IPv6 router
would use in constructing a router advertisement message.  It does not
contain information about the prefixes or other routing specific
information that the router might advertise.  The router should acquire
such information from either the routing tables or from some routing
table specific MIB.

This table is only required for IPv6 router entities.
--- cut here 
-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
