From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [06/11] [TCP]: Put back tcp_timer_bug_msg[] symbol export.
Date: Thu, 10 Mar 2005 23:20:14 +0000
Message-ID: <20050310232014.GA32228@infradead.org>
References: <20050310230519.GA22112@kroah.com> <20050310230843.GG22112@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
        jmorris@redhat.com, yoshfuji@linux-ipv6.org, kaber@coreworks.de,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org, stable@kernel.org
To: Greg KH <greg@kroah.com>
Content-Disposition: inline
In-Reply-To: <20050310230843.GG22112@kroah.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> --- a/net/ipv4/tcp_timer.c	2005-03-09 17:20:38 -08:00
> +++ b/net/ipv4/tcp_timer.c	2005-03-09 17:20:38 -08:00
> @@ -38,6 +38,7 @@
>  
>  #ifdef TCP_DEBUG
>  const char tcp_timer_bug_msg[] = KERN_DEBUG "tcpbug: unknown timer value\n";
> +EXPORT_SYMBOL(tcp_timer_bug_msg);
>  #endif

not complaining about putting this into -stable, but why do people have
TCP_DEBUG turned on for normal builds?
