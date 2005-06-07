From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: IPV6 RFC3542 compliance [PATCH]
Date: Tue, 07 Jun 2005 16:47:49 +0900 (JST)
Message-ID: <20050607.164749.62298775.yoshfuji@linux-ipv6.org>
References: <20050607.160521.73986501.yoshfuji@linux-ipv6.org>
	<OF2D6866A4.ACD65B11-ON88257019.0027E8B0-88257019.002A2862@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: dlstevens@us.ibm.com
In-Reply-To: <OF2D6866A4.ACD65B11-ON88257019.0027E8B0-88257019.002A2862@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <OF2D6866A4.ACD65B11-ON88257019.0027E8B0-88257019.002A2862@us.ibm.com> (at Tue, 7 Jun 2005 00:40:28 -0700), David Stevens <dlstevens@us.ibm.com> says:

> > We can still keep old binaries if we renumber.
> > This is important point.
> > e.g. people, including myself, can keep using old binaries on new 
> kernels.
:
> But old binaries won't work with just that change
> (and making them work is independent of changing
> the numbers).
> 
> For example, old binary:
> 
> IPV6_RTHDR is value 5
> 
> it does:
>         on=1; setsockopt(s, SOL_IPV6, 5, &on);
> and later a recvmsg() where it looks for
> cmsg_type == IPV6_RTHDR (5).
> 
> In the new API, the equivalent:
> 
> IPV6_RTHDR 728
> IPV6_RECVRTHDR 729
> 
>         old binary calls with "5", which you want
> to work, but returns cmsg_type "728" (app doesn't
> find a "5").

No, kernel should send 5, if application use old API, of course.

--yoshfuji
