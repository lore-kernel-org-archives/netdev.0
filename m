From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [RFC/PATCH] ICMPv6 MIB stats per-interface
Date: Tue, 15 Apr 2003 15:59:38 +0900 (JST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030415.155938.23711671.yoshfuji@linux-ipv6.org>
References: <20030415.002915.71906095.yoshfuji@linux-ipv6.org>
	<20030414.090610.117741299.davem@redhat.com>
	<20030415.014047.39346510.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: rddunlap@osdl.org, linux-net@vger.kernel.org, netdev@oss.sgi.com,
	yoshfuji@linux-ipv6.org
Return-path: <linux-net-owner@vger.kernel.org>
To: davem@redhat.com
In-Reply-To: <20030415.014047.39346510.yoshfuji@linux-ipv6.org>
List-Id: netdev.vger.kernel.org

In article <20030415.014047.39346510.yoshfuji@linux-ipv6.org> (at Tue, 15 Apr 2003 01:40:47 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> In article <20030414.090610.117741299.davem@redhat.com> (at Mon, 14 Apr 2003 09:06:10 -0700 (PDT)), "David S. Miller" <davem@redhat.com> says:
> 
> > So we'd then have /proc/net/dev_snmp6/{lo,eth0,eth1} etc.
> > 
> > Ok?
> 
> Okay.  I'd like to see ifIndex in that file, too.

BTW, for example, if we do
 # ip link set eth9 name foobar
if_indextoname() will return foobar. 

we, however, will see /proc/sys/net/ipv6/conf/eth9 instead of 
/proc/sys/net/ipv6/conf/foobar.  This is not good.

Is this just a bug not having NETDEV_CHANGENAME handler to 
rename it?

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
