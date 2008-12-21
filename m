From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH 2/6] ucc_geth: Fix TX watchdog timeout handling
Date: Sun, 21 Dec 2008 06:37:41 +0300
Message-ID: <20081221033741.GB3885@oksana.dev.rtsoft.ru>
References: <20081218182326.GB30682@oksana.dev.rtsoft.ru> <ed82fe3e0812201919o619fd7e7jb87bbec551caa4d@mail.gmail.com>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1251
Cc: Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>,
	Li Yang <leoli@freescale.com>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:35812 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751487AbYLUDhr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Dec 2008 22:37:47 -0500
Content-Disposition: inline
In-Reply-To: <ed82fe3e0812201919o619fd7e7jb87bbec551caa4d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 20, 2008 at 09:19:23PM -0600, Timur Tabi wrote:
> On Thu, Dec 18, 2008 at 12:23 PM, Anton Vorontsov
> <avorontsov@ru.mvista.com> wrote:
> > +static int ucc_geth_close(struct net_device *dev);
> > +static int ucc_geth_open(struct net_device *dev);
> 
> I would prefer that you reorder the functions to eliminate the need
> for forward references.

I'll post a cleanup patch (0/6 series is already in the netdev tree).

Thanks!

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
