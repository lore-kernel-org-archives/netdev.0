From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: RFC: [2.6 patch] disallow modular IPv6
Date: Sun, 28 Sep 2003 20:18:42 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030928231842.GE1039@conectiva.com.br>
References: <20030928225941.GW15338@fs.tum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, davem@redhat.com, pekkas@netcore.fi,
        lksctp-developers@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@fs.tum.de>
Content-Disposition: inline
In-Reply-To: <20030928225941.GW15338@fs.tum.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Mon, Sep 29, 2003 at 12:59:41AM +0200, Adrian Bunk escreveu:
> It seems modular IPv6 doesn't work 100% reliable, e.g. after looking at 
> the code it doesn't seem to be a good idea to compile a kernel without 
> IPv6 support and later build and install IPv6 modules. Is there a great 
> need for modular IPv6 or is the patch below to disallow modular IPv6 OK?

Please, don't... We're going in the all modules direction, not the other
way around, distro (general purpose) kernels would get big bloat in the
static kernel.

- Arnaldo
