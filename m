From: Ralph Doncaster <ralph@istop.com>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 13:19:41 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.51.0306101316560.8755@ns.istop.com>
References: <20030609195652.E35696@shell.cyberus.ca>
 <Pine.LNX.4.51.0306092006420.12038@ns.istop.com> <20030610015311.GB23009@netnation.com>
 <20030610.085600.71109220.davem@redhat.com>
Reply-To: ralph+d@istop.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "sim@netnation.com" <sim@netnation.com>,
	"hadi@shell.cyberus.ca" <hadi@shell.cyberus.ca>,
	"xerox@foonet.net" <xerox@foonet.net>,
	"fw@deneb.enyo.de" <fw@deneb.enyo.de>,
	"netdev@oss.sgi.com" <netdev@oss.sgi.com>,
	"linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030610.085600.71109220.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Tue, 10 Jun 2003, David S. Miller wrote:

>    From: Simon Kirby <sim@netnation.com>
>    Date: Mon, 9 Jun 2003 18:53:12 -0700
>
>    Your CPU use is quite a bit higher than ours.
>
> Yeah, but his faster cpu is all being burnt to a crisp
> doing PIO accesses to the 3c59x card.
>
>    I found that once NAPI was happening, userspace seemed to get a
>    fairly decent amount of time.
>
> Unfortunately, NAPI won't help him with the current way the 3c59x
> driver works.  It needs to provide a way to use MEM I/O before NAPI
> would start to be of use to him.

Well, I've already decided to retire the 3c905cx cards and drop in a
couple of the Pro/1000 cards I recently bought.  Considering the Intel
GigE cards cost me ~$50 now and the 3Coms are ~$45, I'd say anyone willing
to update 3c59x.c has misplaced priorities or too much time on their
hands...

-Ralph

