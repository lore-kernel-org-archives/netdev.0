From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@wide.ad.jp>
Subject: Re: [PATCH] af_pppox: create module infrastructure for protocol
 modules
Date: Tue, 29 Apr 2003 15:46:51 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030429.154651.108798316.yoshfuji@wide.ad.jp>
References: <20030429061227.GJ25361@conectiva.com.br>
	<20030428.222728.48508327.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, mostrows@speakeasy.net, netdev@oss.sgi.com,
   maxk@qualcomm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20030428.222728.48508327.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030428.222728.48508327.davem@redhat.com> (at Mon, 28 Apr 2003 22:27:28 -0700 (PDT)), "David S. Miller" <davem@redhat.com> says:

> So in the TCP/UDP/SCTP example case, a struct sock references the
> TCP/UDP/SCTP module _AND_ the ipv4/ipv6 module.

We probably need to refer IPv4 module as well as IPv6 module 
because of the IPv4-Mapped address feature for IPv6 sockets.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
