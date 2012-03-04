From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 1/2] Netfilter: xt_LOG: Implement ring buffer support
Date: Sun, 04 Mar 2012 14:57:37 -0500
Message-ID: <1330891057.2679.18.camel@frodo>
References: <1329348480-11147-1-git-send-email-richard@nod.at>
	 <20120304190438.GA24722@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Weinberger <richard@nod.at>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com,
	jengelh@medozas.de, basti@b-bl.de
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120304190438.GA24722@1984>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2012-03-04 at 20:04 +0100, Pablo Neira Ayuso wrote:

> > diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
> > index b895d8b..ac62599 100644
> > --- a/net/netfilter/Kconfig
> > +++ b/net/netfilter/Kconfig
> > @@ -533,6 +533,19 @@ config NETFILTER_XT_TARGET_LOG
> >  
> >  	  To compile it as a module, choose M here.  If unsure, say N.
> >  
> > +if NETFILTER_XT_TARGET_LOG
> > +
> > +config NETFILTER_XT_TARGET_LOG_RING
> > +	bool  'Ring buffer support'
> > +	default y
> > +	select RING_BUFFER
> 
> Please, CC the ring buffer author, I'm not familar with that code and
> I'll be happy to have an acknowledgment from him stating that the ring
> buffer bits are OK.

I am Cc'd and I believe I did ack his first set of patches. I have to
admit, I haven't looked too deeply at them again. I can review the last
set and give another ack if you want.

-- Steve
