From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [BK-PATCH 2.4] IPV6: ensure to evaluate checksum
Date: Fri, 21 May 2004 00:55:50 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040521.005550.20498276.yoshfuji@linux-ipv6.org>
References: <20040520.193312.19702393.yoshfuji@linux-ipv6.org>
	<20040520081421.594c5447.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20040520081421.594c5447.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040520081421.594c5447.davem@redhat.com> (at Thu, 20 May 2004 08:14:21 -0700), "David S. Miller" <davem@redhat.com> says:

> I can see both advantages and disadvantages of this
> behavior.  But what I want to ask is if ipv6 RAW is
> being different on purpose, for example does the ipv6
> advanced API specify this perhaps?

Yes. RFC3542 (Advanced Sockets Application Program Interface (API) for 
IPv6) says:
|   For other raw IPv6 sockets (that is, for raw IPv6 sockets created
|   with a third argument other than IPPROTO_ICMPV6), the application
|   must set the new IPV6_CHECKSUM socket option to have the kernel (1)
|   compute and store a checksum for output, and (2) verify the received
|   checksum on input, discarding the packet if the checksum is in error.

--yoshfuji
