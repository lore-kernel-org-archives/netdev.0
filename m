From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: RFC: [2.6 patch] disallow modular IPv6
Date: Sun, 28 Sep 2003 21:32:30 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030929003229.GM1039@conectiva.com.br>
References: <20030928225941.GW15338@fs.tum.de> <20030928231842.GE1039@conectiva.com.br> <20030928232403.GX15338@fs.tum.de> <20030928233909.GG1039@conectiva.com.br> <20030929001439.GY15338@fs.tum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, davem@redhat.com, pekkas@netcore.fi,
   lksctp-developers@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@fs.tum.de>
Content-Disposition: inline
In-Reply-To: <20030929001439.GY15338@fs.tum.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Mon, Sep 29, 2003 at 02:14:39AM +0200, Adrian Bunk escreveu:
> On Sun, Sep 28, 2003 at 08:39:10PM -0300, Arnaldo Carvalho de Melo wrote:
> What about the following solution (the names and help texts for the
> config options might not be optimal, I hope you understand the
> intention):
> 
> config IPV6_SUPPORT
> 	bool "IPv6 support"
> 
> config IPV6_ENABLE
> 	tristate "enable IPv6"
> 	depends on IPV6_SUPPORT
> 
> IPV6_SUPPORT changes structs etc. and IPV6_ENABLE is responsible for 
> ipv6.o .

Humm, and the idea is? This seems confusing, could you elaborate on why such
scheme is a good thing?

- Arnaldo
