From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: /proc/net/* read drops data
Date: Sat, 06 Sep 2003 16:04:58 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030906.160458.39800982.yoshfuji@linux-ipv6.org>
References: <20030904004638.1d4b001d.davem@redhat.com>
	<Pine.GSO.4.33.0309041223430.13584-100000@sweetums.bluetronic.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, netdev@oss.sgi.com
In-Reply-To: <Pine.GSO.4.33.0309041223430.13584-100000@sweetums.bluetronic.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.GSO.4.33.0309041223430.13584-100000@sweetums.bluetronic.net> (at Thu, 4 Sep 2003 12:25:16 -0400 (EDT)), Ricky Beam <jfbeam@bluetronic.net> says:

> >This fix looks good to me.  Applied.
> 
> The list:
> (file)			(bs=1)	(bs=10000)
> /proc/net/igmp		122     191
> /proc/net/route		128     384
> /proc/net/rt_acct	0	4096
> /proc/net/rt_cache	384     512
> /proc/net/tcp		1800    1950
> /proc/net/udp		1024    1152

Well, I'm about to post 3 patches.

[1/3] /proc/net/{igmp,msfilter,raw,rt_cache,ip6_flowlabel,msfilter6,raw6} may drop some data
[2/3] /proc/net/if_inet6 may drop some data
[3/3] clean up /proc/net/{anycast6,igmp6}

Note 0: These confilct with SEQ_START_TOKEN patches; 
        I'll regenerate if SEQ_START_TOKEN accepted.
Note 1: /proc/net/rt_acct does not use seq_file
Note 2: /proc/net/{route,tcp,tcp6} is not fixed by these

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
