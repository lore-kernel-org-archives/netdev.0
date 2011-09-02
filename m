From: Dan Carpenter <error27@gmail.com>
Subject: Re: [patch -next] caif: add error handling for allocation
Date: Fri, 2 Sep 2011 18:51:27 +0300
Message-ID: <20110902155127.GI2430@shale.localdomain>
References: <20110902080716.GF2430@shale.localdomain>
 <CAJK669Yb6V=xr9ZvQGOKGEvmzO1JGhrHD+sR69b04EQxUjOOrQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	"open list:CAIF NETWORK LAYER" <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Sjur =?iso-8859-1?Q?Br=E6ndeland?= <sjurbren@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:43419 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752945Ab1IBPxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2011 11:53:51 -0400
Content-Disposition: inline
In-Reply-To: <CAJK669Yb6V=xr9ZvQGOKGEvmzO1JGhrHD+sR69b04EQxUjOOrQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 02, 2011 at 11:40:23AM +0200, Sjur Br=E6ndeland wrote:
> Thank you for your patch.
> When reviewing this I found another potential memory leak as well.
> If cffrml_create fails, we might be leaking the phy_driver.
> So perhaps you could do kfree(phy_driver) in out_err: as well, while
> you are at it?
>=20

Good point.  A kfree(phy_driver) would fix the leak.  But why does
cfserl_create() return &this->layer; instead of just "return this;"
Their equivalent now, but if you change the cfserl struct it will
break the kfree().

I'll be travelling for a while, so I may be out of reach until
Wednessday.

regards,
dan carpenter
