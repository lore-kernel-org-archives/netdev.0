From: David VomLehn <dvomlehn@cisco.com>
Subject: Re: [PATCH 3/5] initdev:kernel: Await console discovery, v5
Date: Mon, 4 May 2009 17:17:56 -0700
Message-ID: <20090505001756.GB29124@cuplxvomd02.corp.sa.net>
References: <20090502022756.GA15838@cuplxvomd02.corp.sa.net> <20090502113825.11bc7876@linux-lm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	linux-usb@vger.kernel.org, greg@kroah.com,
	linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	arjan@infradead.org
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090502113825.11bc7876@linux-lm>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 01, 2009 at 11:38:25PM -0400, Ming Lei wrote:
> On Fri, 1 May 2009 19:27:56 -0700
> David VomLehn <dvomlehn@cisco.com> wrote:
...
> > diff --git a/drivers/accessibility/braille/braille_console.c
> > b/drivers/accessibility/braille/braille_console.c index
> > d672cfe..4420ac3 100644 ---
> > +
> > +	initdev_register(BOOTDEV_CONSOLE);
> 
> Should it be initdev_registered(BOOTDEV_CONSOLE)?

Yes.

> Lei Ming

Thanks!

David VomLehn
