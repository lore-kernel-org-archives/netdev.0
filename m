From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] seastar - SeaStar Ethernet driver
Date: Tue, 02 Feb 2010 22:12:41 +0000
Message-ID: <1265148761.2622.10.camel@achroite.uk.solarflarecom.com>
References: <20100202205845.GE5246@hawkeye.sandia.gov>
	 <4B68A03E.1010403@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Kevin Pedretti <ktpedre@sandia.gov>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B68A03E.1010403@xenotime.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-02-02 at 13:59 -0800, Randy Dunlap wrote:
> On 02/02/10 12:58, Kevin Pedretti wrote:
[...]
> > +static void seastar_map_host_region(struct ss_priv *ssp, const void *addr)
> > +{
> > +	/* Round addr to the nearest 128 MB */
> > +	unsigned long raw_paddr = __pa(addr);
> > +	unsigned long paddr = raw_paddr&  ~((1<<  28) - 1);
> > +
> > +	htb_map[8] = 0x8000 | ((paddr>>  28) + 0);
> > +	htb_map[9] = 0x8000 | ((paddr>>  28) + 1);
> 
> space before <<, &, and >>
[...]

The spacing looked correct here.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
