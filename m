From: Paul P Komkoff Jr <i@stingr.net>
Subject: Re: [PATCH] [RFC] Support for wccp version 1 and 2 in ip_gre.c
Date: Tue, 14 Sep 2004 16:39:51 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040914123951.GL4141@stingr.sgu.ru>
References: <20040913051706.GB26337@stingr.sgu.ru> <20040911194108.GS28258@stingr.sgu.ru> <20040912170505.62916147.davem@davemloft.net> <20040913051706.GB26337@stingr.sgu.ru> <5.1.0.14.2.20040914184652.03e24de0@171.71.163.14>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "David S. Miller" <davem@davemloft.net>, Paul P Komkoff Jr <i@stingr.net>,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Lincoln Dale <ltd@cisco.com>
Content-Disposition: inline
In-Reply-To: <5.1.0.14.2.20040914184652.03e24de0@171.71.163.14>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Replying to Lincoln Dale:
> the logic is correct, but it may make sense to call the appropriate 
> netfilter hook again with the "unwrapped" GRE packet, as otherwise 
> packets-inside-GRE represent a possible security hole where one can inject 
> packets externally and bypass firewall rules.

>From what I observe, netfilter hooks *are* called for unwrapped packets.
Either for usual IP packets  passed from GRE tunnel, or for demangled
wccp packets.

-- 
Paul P 'Stingray' Komkoff Jr // http://stingr.net/key <- my pgp key
 This message represents the official view of the voices in my head
