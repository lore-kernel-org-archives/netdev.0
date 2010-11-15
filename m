From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: the future of ethtool
Date: Mon, 15 Nov 2010 13:14:53 -0800
Message-ID: <20101115131453.16958d68@nehalam>
References: <4CE18CEA.5080502@garzik.org>
	<1289852326.2586.32.camel@bwh-desktop>
	<20101115124428.7b857ccb@nehalam>
	<1289855642.2586.38.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, NetDev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47856 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758519Ab0KOVO6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Nov 2010 16:14:58 -0500
In-Reply-To: <1289855642.2586.38.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Nov 2010 21:14:02 +0000
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Mon, 2010-11-15 at 12:44 -0800, Stephen Hemminger wrote:
> [...]
> > My views are simple:
> > 
> > Ethtool needs to be an extension of existing netlink API for interfaces.
> >   - handles multiple values per transaction
> >   - extensible
> [...]
> 
> Are you suggesting to send and receive the existing ethtool command and
> result structures (with some wrapping) through netlink?  Or some larger
> change to the API?

The existing ioctl base API should be kept as legacy and something
better developed.
