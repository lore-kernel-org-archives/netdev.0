From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: Oops in 2.6.0-test[89] in tcp_v4_get_port (kernel with IPv6
 enabled)
Date: Sat, 01 Nov 2003 12:15:37 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031101.121537.105697095.yoshfuji@linux-ipv6.org>
References: <20031031145542.28e8b820.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org, akpm@digeo.com
Return-path: <netdev-bounce@oss.sgi.com>
To: raffaele.brancaleoni@sun.com
In-Reply-To: <20031031145542.28e8b820.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20031031145542.28e8b820.akpm@osdl.org> (at Fri, 31 Oct 2003 14:55:42 -0800), Andrew Morton <akpm@osdl.org> says:

> Date: Fri, 31 Oct 2003 12:30:06 +0100
> From: Raffaele Brancaleoni <raffaele.brancaleoni@sun.com>
> To: linux-kernel@vger.kernel.org
> Subject: Oops in 2.6.0-test[89] in tcp_v4_get_port (kernel with IPv6 enabled)
:
> I just encountered a oops with kernels 2.6.0-test8 and -test9 (system
> freezes the hard way, not even magic-key works). Problem does not exist
> in 2.4.20.
:
> I found a thread about similar issue in the archive
> (thread subject: "oops in inet_bind/tcp_v4_get_port"). Yoshifuji Hideaki 
>   provided a patch but unfortunately it causes some problems with 
> ip_nat_helper and ip_nat_cores modules compilation (duplicate functions 
> definitions)...

Please try the latest bk tree (with IPv6 enable, of course).  Thanks.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
