From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [06/11] [TCP]: Put back tcp_timer_bug_msg[] symbol export.
Date: Thu, 10 Mar 2005 15:47:16 -0800
Message-ID: <20050310154716.5694bf69.davem@davemloft.net>
References: <20050310230519.GA22112@kroah.com>
	<20050310230843.GG22112@kroah.com>
	<20050310232014.GA32228@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
        jmorris@redhat.com, yoshfuji@linux-ipv6.org, kaber@coreworks.de,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org, stable@kernel.org
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20050310232014.GA32228@infradead.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 10 Mar 2005 23:20:14 +0000
Christoph Hellwig <hch@infradead.org> wrote:

> > --- a/net/ipv4/tcp_timer.c	2005-03-09 17:20:38 -08:00
> > +++ b/net/ipv4/tcp_timer.c	2005-03-09 17:20:38 -08:00
> > @@ -38,6 +38,7 @@
> >  
> >  #ifdef TCP_DEBUG
> >  const char tcp_timer_bug_msg[] = KERN_DEBUG "tcpbug: unknown timer value\n";
> > +EXPORT_SYMBOL(tcp_timer_bug_msg);
> >  #endif
> 
> not complaining about putting this into -stable, but why do people have
> TCP_DEBUG turned on for normal builds?

It is on in everyone's build unless they edit include/net/tcp.h
