From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@wide.ad.jp>
Subject: RE: Linux IPv6 Bind failure with Invalid Argument
Date: Sat, 20 Apr 2002 04:46:08 +0900
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020420044608I.yoshfuji@wide.ad.jp>
References: <AA70E30319FAD411AC6E00A0C95D7ABD01EE7692@fmsmsx61.fm.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arif7290@hotmail.com, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: m_hossain@trillium.com
In-Reply-To: <AA70E30319FAD411AC6E00A0C95D7ABD01EE7692@fmsmsx61.fm.intel.com>
List-Id: netdev.vger.kernel.org

In article <AA70E30319FAD411AC6E00A0C95D7ABD01EE7692@fmsmsx61.fm.intel.com> (at Fri, 19 Apr 2002 12:04:09 -0700), "Hossain, Mohammad" <m_hossain@trillium.com> says:

> Hello Hideaki,
>   It seems my IPv6 address has link scope only.
>   What value should be put in the scope id to pass the bind call? 
>   Is it because of the address has scope link???

ifindex at this moment.

getaddrinfo() will help you.
give fe80::xxx%ethX as host where ethX is eth0 
or whatever.

--yoshfuji
