From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH 2/2] usbnet: use MII hooks only if CONFIG_MII is enabled
Date: Sat, 28 Oct 2006 15:30:18 -0700
Message-ID: <200610281530.22743.david-b@pacbell.net>
References: <Pine.LNX.4.64.0610231618510.3962@g5.osdl.org> <200610281410.13679.david-b@pacbell.net> <20061028211342.GA23360@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, greg@kroah.com, link@miggy.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Randy Dunlap <randy.dunlap@oracle.com>, toralf.foerster@gmx.de,
	torvalds@osdl.org, zippel@linux-m68k.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964896AbWJ1Wa2@vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20061028211342.GA23360@infradead.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 28 October 2006 2:13 pm, Christoph Hellwig wrote:
> 
> I still don't quite like the approach.  What about simply putting
> the mii using functions into usbnet-mii.c and let makefile doing
> all the work?  This would require a second set of ethtool ops,
> but I'd actually consider that a cleanup, as it makes clear which
> one we're using and allows to kill all the checks for non-mii
> hardware in the methods.

Feel free to do such a patch yourself, so long as the MII doesn't
go into a separate module.  You'll have to also modify the two
Ethernet adapters currently using that usbnet core code (and MII).

That'd still feel like needless complexity to me, though.  So
unless you're keen on doing that quickly, I'd say to just merge
the two existing patches and be done with it.

- Dave
