From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] Implementation for IPv6 MIB:ipv6AddressTable
Date: Tue, 07 Oct 2003 20:35:18 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031007.203518.82055464.yoshfuji@linux-ipv6.org>
References: <20031007034051.3fcb3218.davem@redhat.com>
	<200310071116.PAA30760@yakov.inr.ac.ru>
	<20031007041246.13aa0391.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, mashirle@us.ibm.com, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20031007041246.13aa0391.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20031007041246.13aa0391.davem@redhat.com> (at Tue, 7 Oct 2003 04:12:46 -0700), "David S. Miller" <davem@redhat.com> says:

> On Tue, 7 Oct 2003 15:16:20 +0400 (MSD)
> kuznet@ms2.inr.ac.ru wrote:
> 
> > Actually, this does not depend on our implementation. If people implement
> > a MIB, required precision of these times is prescribed in the rfc.
> > And this is definitely not jiffies.
> 
> Right, Shirley what is it?

The type is TimeTicks (RFC2578) via TimeStamp (RFC2579).
Thus, uint32_t counter in 1/100 sec. unit.

--yoshfuji
