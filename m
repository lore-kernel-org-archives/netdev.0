From: "David S. Miller" <davem@redhat.com>
Subject: Re: 2.4.23 and CONFIG_PROC_FS=n
Date: Sun, 30 Nov 2003 10:58:29 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031130105829.478e408a.davem@redhat.com>
References: <Pine.GSO.4.21.0311301949180.23461-100000@waterleaf.sonytel.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Geert Uytterhoeven <geert@linux-m68k.org>
In-Reply-To: <Pine.GSO.4.21.0311301949180.23461-100000@waterleaf.sonytel.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 30 Nov 2003 19:55:48 +0100 (MET)
Geert Uytterhoeven <geert@linux-m68k.org> wrote:

> 
> When compiling 2.4.23 with CONFIG_PROC_FS disabled, I found a few
> network-related files that don't compile:
>   1. net/atm/br2684.c 
>   2. net/core/pktgen.c
>   3. net/ipv4/netfilter/ipt_recent.c
> 
> The patch below fixes 1 and 3. Note that 3 still generates a compiler warning
> (`ip_list_perms' defined but not used).

Thanks Geert, I'll review and probably apply this.

> The packet generator is a bit trickier, since its functionality seems to
> depend completely on the proc file system.

Yes, it does, should just add the dependency to the config.

Thanks again.
