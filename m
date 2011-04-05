From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 12/34] isdn/diva: Drop __TIME__ usage
Date: Tue, 05 Apr 2011 16:37:41 +0100
Message-ID: <1302017861.2932.13.camel@bwh-desktop>
References: <1302015561-21047-1-git-send-email-mmarek@suse.cz>
	 <1302015561-21047-13-git-send-email-mmarek@suse.cz>
	 <alpine.DEB.2.00.1104051709040.7262@justus.melware.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michal Marek <mmarek@suse.cz>, linux-kbuild@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Armin Schindler <armin@melware.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1104051709040.7262@justus.melware.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-04-05 at 17:10 +0200, Armin Schindler wrote:
> On Tue, 5 Apr 2011, Michal Marek wrote:
> > The kernel already prints its build timestamp during boot, no need to
> > repeat it in random drivers and produce different object files each
> > time.
> 
> The module can be build separately from the kernel, therefore it can have
> an own build timestamp.
[...]

If you want to distribute an out-of-tree version, that's your own
business.  It shouldn't limit what is done with the in-tree version.
Perhaps we could make modpost add a build timestamp to OOT modules,
though.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
