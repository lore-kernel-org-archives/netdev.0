From: josh@joshtriplett.org
Subject: Re: [PATCH 3/3] printk: implement support for extended console
 drivers
Date: Mon, 29 Jun 2015 09:11:24 -0700
Message-ID: <20150629161124.GA1348@cloud>
References: <1430318704-32374-1-git-send-email-tj@kernel.org>
 <1430318704-32374-4-git-send-email-tj@kernel.org>
 <CAMuHMdWwH-3kx1ma5KE=fP94by8boxM_QYqPKpU=YJw8t3hYeg@mail.gmail.com>
 <20150629152805.GM15805@mtj.duckdns.org>
 <CAMuHMdXTn0+z4PV9UVZZmpMdk_-JUc4x-GqZweOhQyYMTzSOGQ@mail.gmail.com>
 <20150629154914.GQ15805@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, pmladek@suse.cz,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kay Sievers <kay@vrfy.org>,
	Linux Embedded <linux-embedded@vger.kernel.org>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150629154914.GQ15805@mtj.duckdns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 29, 2015 at 11:49:14AM -0400, Tejun Heo wrote:
> On Mon, Jun 29, 2015 at 05:47:49PM +0200, Geert Uytterhoeven wrote:
> > > netconsole itself is optional & modular.  I'm not sure making further
> > > splits is called for, especially given the use cases.
> > 
> > It could be a hidden option, selected by its users (e.g. netconsole).
> 
> Hmmm... what do you mean?

config PRINTK_BITS_THAT_NETCONSOLE_NEEDS

(no help text or prompt)

config NETCONSOLE
    select PRINTK_BITS_THAT_NETCONSOLE_NEEDS

That would ensure that the bits added to printk don't get compiled in
unless CONFIG_NETCONSOLE=y.

- Josh Triplett
