From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH] (10/11) netrom - convert /proc interface to seq_file
Date: Thu, 14 Aug 2003 14:25:39 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030814172539.GD1785@conectiva.com.br>
References: <20030813154635.376df59b.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, Jeroen Vreeken <pe1rxq@amsat.org>,
   linux-hams@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20030813154635.376df59b.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Wed, Aug 13, 2003 at 03:46:35PM -0700, Stephen Hemminger escreveu:
> Convert netrom /proc interface to seq_file.
> 
> diff -Nru a/include/net/netrom.h b/include/net/netrom.h
> --- a/include/net/netrom.h	Wed Aug 13 13:54:19 2003
> +++ b/include/net/netrom.h	Wed Aug 13 13:54:19 2003
> +		seq_printf(seq, "%-9s ", ax2asc(&nr->user_addr));
> +		seq_printf(seq, "%-9s ", ax2asc(&nr->dest_addr));
> +		seq_printf(seq, 
> +"%-9s %-3s  %02X/%02X %02X/%02X %2d %3d %3d %3d %3lu/%03lu %2lu/%02lu %3lu/%03lu %3lu/%03lu %2d/%02d %3d %5d %5d %ld\n",

<nitpick> why not just one seq_printf call? </nitpick>
