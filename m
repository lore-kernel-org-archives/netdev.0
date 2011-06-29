From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH 00/12] Fix various section mismatches and build errors.
Date: Wed, 29 Jun 2011 17:19:21 +0100
Message-ID: <20110629161921.GA25833@linux-mips.org>
References: <17dd5038b15d7135791aadbe80464a13c80758d3.1309182742.git.ralf@linux-mips.org>
 <20110627.221257.1290251511587162468.davem@davemloft.net>
 <20110629130711.GA15649@linux-mips.org>
 <1309355899.2551.4.camel@mulgrave>
 <20110629151424.GD18023@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	alan@linux.intel.com, bcasavan@sgi.com, airlied@linux.ie,
	grundler@parisc-linux.org, perex@perex.cz, rpurdie@rpsys.net,
	klassert@mathematik.tu-chemnitz.de, tj@kernel.org,
	dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org,
	linux-mips@linux-mips.org, linux-scsi@vger.kernel.org,
	linux-serial@vger.kernel.org, netdev@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <linux-serial-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110629151424.GD18023@kroah.com>
Sender: linux-serial-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 29, 2011 at 08:14:24AM -0700, Greg KH wrote:

> 
> On Wed, Jun 29, 2011 at 08:58:19AM -0500, James Bottomley wrote:
> > I think we should simply concentrate on __init and __exit; that's where
> > most of the discard value lies and stop expending huge efforts on the
> > __devX stuff which adds huge complexity for no real gain.
> 
> I have long felt that those __devX markings should just go away as they
> cause nothing but problems and have no real gain as you point out.

The suggestion to do that has been floated around before but seems to
have missed sufficient thrust.  I'm all for it; the manual tagging with
__devX has not been very efficient on developer time.  I just want to see
meaningful warnings again over all that noise the current mechanisn may
produce.

  Ralf
