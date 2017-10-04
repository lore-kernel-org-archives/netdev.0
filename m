From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 0/3] A own subdirectory for shared TCP code
Date: Wed, 4 Oct 2017 22:27:49 +0200
Message-ID: <20171004202749.GB13247@lunn.ch>
References: <20171003222213.7996-1-richard_siegfried@systemli.org>
 <20171003.160338.1370433279322133749.davem@davemloft.net>
 <d7237d11-ec83-0ef6-d201-da8b99c94b88@systemli.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Richard Siegfried <richard_siegfried@systemli.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:39607 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751161AbdJDU1z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Oct 2017 16:27:55 -0400
Content-Disposition: inline
In-Reply-To: <d7237d11-ec83-0ef6-d201-da8b99c94b88@systemli.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 04, 2017 at 08:54:17PM +0200, Richard Siegfried wrote:
> On 04/10/17 01:03, David Miller wrote:
> > As someone who has to do backports regularly to -stable, there is no way
> > I am applying this.
> > 
> > Sorry.
> Okay, I see.
> 
> Is grouping files into subdirectories something generally
> unwanted/unlikely to be applied or is this specific to TCP / networking?
> 
> Because there are several other places in the source tree where I would
> like to group things.

Hi Richard

It is generally unwanted.

Have you tried back porting patches when the directory structure has
changed? Files have moved around? It makes it a lot harder to
do. Meaning patches are going to be back ported less often. Fixes
which could be security relevant might not get back ported, etc.

Kernel 4.4 is going to be supported until 2022. So moving files around
is going to make Greg Kroah-Hartman life more difficult for the next 5
years.

	Andrew
