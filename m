From: David Miller <davem@davemloft.net>
Subject: Re: powerpc allmodconfig
Date: Thu, 16 Oct 2008 00:36:44 -0700 (PDT)
Message-ID: <20081016.003644.74134312.davem@davemloft.net>
References: <20081015213337.a99a9595.akpm@linux-foundation.org>
	<20081015.220247.262683261.davem@davemloft.net>
	<Pine.LNX.4.64.0810160930300.25933@anakin>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, tiwai@suse.de,
	linux-ext4@vger.kernel.org, netdev@vger.kernel.org,
	linux-ide@vger.kernel.org, bzolnier@gmail.com,
	marek.vasut@gmail.com, dwmw2@infradead.org, mark.fasheh@oracle.com,
	ralf@linux-mips.org, mchehab@infradead.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: geert@linux-m68k.org
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0810160930300.25933@anakin>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Thu, 16 Oct 2008 09:31:29 +0200 (CEST)

> On Wed, 15 Oct 2008, David Miller wrote:
> > > kernel/resource.c: In function '__reserve_region_with_split':
> > > kernel/resource.c:554: warning: format '%llx' expects type 'long long unsigned int', but argument 3 has type 'resource_size_t'
> > > kernel/resource.c:554: warning: format '%llx' expects type 'long long unsigned int', but argument 4 has type 'resource_size_t'
> > > kernel/resource.c:554: warning: format '%llx' expects type 'long long unsigned int', but argument 6 has type 'resource_size_t'
> > > kernel/resource.c:554: warning: format '%llx' expects type 'long long unsigned int', but argument 7 has type 'resource_size_t'
> > 
> > Known issue, Ben wants to add a new variant of %pX in order to print resources so that
> > resource_size_t vs. unsigned long stuff doesn't matter like this any more.
> 
> Will still give a warning, as resource_size_t is not a pointer.

The idea is to pass in a pointer to the resource struct,
and the %pX variant specified says what part to print.
