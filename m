From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6 MIB:ipv6DefaultRouterTable
Date: Fri, 16 Jan 2004 03:36:22 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040116.033622.83599316.yoshfuji@linux-ipv6.org>
References: <OF87A9D639.F6A8D26B-ON88256E1C.0064AD99@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mashirle@us.ibm.com, davem@redhat.com, kuznet@ms2.inr.ac.ru,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: xma@us.ibm.com
In-Reply-To: <OF87A9D639.F6A8D26B-ON88256E1C.0064AD99@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <OF87A9D639.F6A8D26B-ON88256E1C.0064AD99@us.ibm.com> (at Thu, 15 Jan 2004 10:26:21 -0800), Shirley Ma <xma@us.ibm.com> says:

> This is a bug fix for ipDefaultRouter Table. According to the new IP MIBs,
> the DefaultRouterLifeTime(expire) entry in this table is unsigned 32. It
> measures the remaining length of time in seconds. If it's expire, the value
> should be 0.

Kernel does not have to provide MIB in as-is format.

--yoshfuji
