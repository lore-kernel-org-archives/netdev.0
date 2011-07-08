From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH] drivers/net: Omit check for multicast bit in
	netdev_for_each_mc_addr
Date: Fri, 8 Jul 2011 10:42:18 +0200
Message-ID: <20110708084218.GK8334@distanz.ch>
References: <1310112386-13716-1-git-send-email-tklauser@distanz.ch> <1310114109.2755.18.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jaroslav Kysela <perex@perex.cz>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from symlink.to.noone.org ([85.10.207.172]:53906 "EHLO sym.noone.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753936Ab1GHImU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jul 2011 04:42:20 -0400
Content-Disposition: inline
In-Reply-To: <1310114109.2755.18.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2011-07-08 at 10:35:09 +0200, Joe Perches <joe@perches.com> wrote:
> On Fri, 2011-07-08 at 10:06 +0200, Tobias Klauser wrote:
> > There is no need to check for the address being a multicast address in
> > the netdev_for_each_mc_addr loop, so remove it.
> > 
> > There is no need to check for the address being a multicast address in
> > the netdev_for_each_mc_addr loop, so remove it.
> 
> Thanks Tobias.
> 
> The commit message is a bit redundant, but this looks
> good to me.

Oops, sorry. The first part should've gone away.

David, I can resend it with an adjusted commit message if you want, so
you don't need to edit it.
