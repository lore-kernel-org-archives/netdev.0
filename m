From: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Subject: Re: [PATCH] atl1c: Add support for Atheros AR8152 and AR8152
Date: Fri, 22 Oct 2010 13:37:07 -0700
Message-ID: <20101022203707.GD16209@tux>
References: <1286759930.2955.285.camel@localhost>
 <20101010.210304.71107535.davem@davemloft.net>
 <20101011184835.GA10049@tux>
 <1286836101.2955.293.camel@localhost>
 <20101012004503.GI10049@tux>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jie Yang <Jie.Yang@Atheros.com>, <linux-team@atheros.com>
To: Luis Rodriguez <Luis.Rodriguez@Atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.atheros.com ([12.19.149.2]:65503 "EHLO mail.atheros.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752469Ab0JVUhN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Oct 2010 16:37:13 -0400
Received: from mail.atheros.com ([10.10.20.105])
	by sidewinder.atheros.com
	for <netdev@vger.kernel.org>; Fri, 22 Oct 2010 13:37:03 -0700
Content-Disposition: inline
In-Reply-To: <20101012004503.GI10049@tux>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 11, 2010 at 05:45:03PM -0700, Luis Rodriguez wrote:
> On Mon, Oct 11, 2010 at 03:28:21PM -0700, Ben Hutchings wrote:
> > On Mon, 2010-10-11 at 11:48 -0700, Luis R. Rodriguez wrote:
> > > On Sun, Oct 10, 2010 at 09:03:04PM -0700, David Miller wrote:
> > > > From: Ben Hutchings <ben@decadent.org.uk>
> > > > Date: Mon, 11 Oct 2010 02:18:50 +0100
> > > > 
> > > > > Your commit 496c185c9495629ef1c65387cb2594578393cfe0 "atl1c: Add support
> > > > > for Atheros AR8152 and AR8152" included the following changes:
> > > >  ...
> > > > >> +		if (hw->nic_type == athr_l1c || hw->nic_type == athr_l2c_b) {
> > > >  ...
> > > > >> +	if ((hw->nic_type == athr_l1c || hw->nic_type == athr_l2c)) {
> > > >  ...
> > > > > Shouldn't the first if-statement use the same condition as the second
> > > > > i.e. matching the previously-defined hardware types athr_l1c and
> > > > > athr_l2c?
> > > > 
> > > > Yeah that definitely looks like a bug to me.
> > > 
> > > Good catch, unfortunatley I don't have the source code I used to port
> > > this work the day I did this anymore locally, so adding 
> > > Jie Yang who is actually our maintainer for this driver.
> > > 
> > > Jie, can you please confirm if this patch is correct?
> > 
> > I was suggesting that the first condition was wrong and the second was
> > right.
> 
> Heh, thanks, Jie can you review?

Jie, have you had any chance to review?

  Luis
