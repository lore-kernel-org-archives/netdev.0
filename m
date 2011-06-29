From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 00/12] Fix various section mismatches and build errors.
Date: Wed, 29 Jun 2011 08:14:24 -0700
Message-ID: <20110629151424.GD18023@kroah.com>
References: <17dd5038b15d7135791aadbe80464a13c80758d3.1309182742.git.ralf@linux-mips.org>
 <20110627.221257.1290251511587162468.davem@davemloft.net>
 <20110629130711.GA15649@linux-mips.org>
 <1309355899.2551.4.camel@mulgrave>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	alan@linux.intel.com, bcasavan@sgi.com, airlied@linux.ie,
	grundler@parisc-linux.org, perex@perex.cz, rpurdie@rpsys.net,
	klassert@mathematik.tu-chemnitz.de, tj@kernel.org,
	dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org,
	linux-mips@linux-mips.org, linux-scsi@vger.kernel.org,
	linux-serial@vger.kernel.org, netdev@vger.kernel.org
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4.smtp.messagingengine.com ([66.111.4.28]:52517 "EHLO
	out4.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755346Ab1F2PQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2011 11:16:12 -0400
Content-Disposition: inline
In-Reply-To: <1309355899.2551.4.camel@mulgrave>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 29, 2011 at 08:58:19AM -0500, James Bottomley wrote:
> I think we should simply concentrate on __init and __exit; that's where
> most of the discard value lies and stop expending huge efforts on the
> __devX stuff which adds huge complexity for no real gain.

I have long felt that those __devX markings should just go away as they
cause nothing but problems and have no real gain as you point out.

greg k-h
