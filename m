From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] (10/11) netrom - convert /proc interface to seq_file
Date: Thu, 14 Aug 2003 11:30:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030814113025.2b40be14.shemminger@osdl.org>
References: <20030813154635.376df59b.shemminger@osdl.org>
	<20030814172539.GD1785@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, Jeroen Vreeken <pe1rxq@amsat.org>,
   linux-hams@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <20030814172539.GD1785@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 14 Aug 2003 14:25:39 -0300
Arnaldo Carvalho de Melo <acme@conectiva.com.br> wrote:

> Em Wed, Aug 13, 2003 at 03:46:35PM -0700, Stephen Hemminger escreveu:
> > Convert netrom /proc interface to seq_file.
> > 
> > diff -Nru a/include/net/netrom.h b/include/net/netrom.h
> > --- a/include/net/netrom.h	Wed Aug 13 13:54:19 2003
> > +++ b/include/net/netrom.h	Wed Aug 13 13:54:19 2003
> > +		seq_printf(seq, "%-9s ", ax2asc(&nr->user_addr));
> > +		seq_printf(seq, "%-9s ", ax2asc(&nr->dest_addr));
> > +		seq_printf(seq, 
> > +"%-9s %-3s  %02X/%02X %02X/%02X %2d %3d %3d %3d %3lu/%03lu %2lu/%02lu %3lu/%03lu %3lu/%03lu %2d/%02d %3d %5d %5d %ld\n",
> 
> <nitpick> why not just one seq_printf call? </nitpick>

ax2asc() returns a pointer to static buffer.
