From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: [PATCH] pegasos_eth.c: Fix compile error over MV643XX_ defines
Date: Tue, 30 Oct 2007 03:44:59 -0400
Message-ID: <43e72e890710300044o60bfc46cv8815226e39634996@mail.gmail.com>
References: <20071029212729.GA4074@pogo>
	 <20071029223900.GA7097@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	"Jeff Garzik" <jeff@garzik.org>,
	"Lennert Buytenhek" <buytenh@wantstofly.org>,
	"Tzachi Perelstein" <tzachi@marvell.com>
To: "Dale Farnsworth" <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.181]:51228 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752183AbXJ3HpB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 03:45:01 -0400
Received: by py-out-1112.google.com with SMTP id u77so3373098pyb
        for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 00:44:59 -0700 (PDT)
In-Reply-To: <20071029223900.GA7097@xyzzy.farnsworth.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/29/07, Dale Farnsworth <dale@farnsworth.org> wrote:
> On Mon, Oct 29, 2007 at 05:27:29PM -0400, Luis R. Rodriguez wrote:
> > This commit made an incorrect assumption:
> > --
> > Author: Lennert Buytenhek <buytenh@wantstofly.org>
> >  Date:   Fri Oct 19 04:10:10 2007 +0200
> >
> >     mv643xx_eth: Move ethernet register definitions into private header
> >
> >     Move the mv643xx's ethernet-related register definitions from
> >     include/linux/mv643xx.h into drivers/net/mv643xx_eth.h, since
> >     they aren't of any use outside the ethernet driver.
> >
> >     Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> >     Acked-by: Tzachi Perelstein <tzachi@marvell.com>
> >     Signed-off-by: Dale Farnsworth <dale@farnsworth.org>
> > --
> >
> > arch/powerpc/platforms/chrp/pegasos_eth.c made use of a 3 defines there.
> >
> > mcgrof@pogo:~/devel/wireless-2.6$ git-describe
> >
> > v2.6.24-rc1-138-g0119130
> >
> > This patch fixes this by internalizing 3 defines onto pegasos which are
> > simply no longer available elsewhere. Without this your compile will fail
>
> That compile failure was fixed in commit
> 30e69bf4cce16d4c2dcfd629a60fcd8e1aba9fee by Al Viro.
>
> However, as I examine that commit, I see that it defines offsets from
> the eth block in the chip, rather than the full chip registeri block
> as the Pegasos 2 code expects.  So, I think it fixes the compile
> failure, but leaves the Pegasos 2 broken.
>
> Luis, do you have Pegasos 2 hardware?  Can you (or anyone) verify that
> the following patch is needed for the Pegasos 2?

Nope, sorry.

  Luis
