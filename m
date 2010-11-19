From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] SuperH IrDA: correct Baud rate error correction
Date: Thu, 18 Nov 2010 17:05:04 -0800
Message-ID: <1290128704.1817.56.camel@Joe-Laptop>
References: <20101119012402.43e9aa61@absol.kitzblitz>
	 <20101118164150.22aa7e16@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Nicolas Kaiser <nikai@nikai.net>, Samuel Ortiz <samuel@sortiz.org>,
	Kuninori Morimoto <morimoto.kuninori@renesas.com>,
	irda-users@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1560 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752023Ab0KSBFK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Nov 2010 20:05:10 -0500
In-Reply-To: <20101118164150.22aa7e16@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-11-18 at 16:41 -0800, Stephen Hemminger wrote:
> On Fri, 19 Nov 2010 01:24:02 +0100
> Nicolas Kaiser <nikai@nikai.net> wrote:
> >  	u32 rate_err_array[] = {
> > -		0000, 0625, 1250, 1875,
> > +		   0,  625, 1250, 1875,
> >  		2500, 3125, 3750, 4375,
> >  		5000, 5625, 6250, 6875,
> >  		7500, 8125, 8750, 9375,
> While you are at it make that table const.

Good find Nicolas.

static const might be better still.


