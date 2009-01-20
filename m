From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phylib: unsigneds go unnoticed
Date: Mon, 19 Jan 2009 17:14:32 -0800 (PST)
Message-ID: <20090119.171432.155456999.davem@davemloft.net>
References: <4973B3E7.6080203@gmail.com>
	<20090118.212512.149560148.davem@davemloft.net>
	<49744AE6.9@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulius.zaleckas@teltonika.lt, netdev@vger.kernel.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39062
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754919AbZATBOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 20:14:30 -0500
In-Reply-To: <49744AE6.9@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Mon, 19 Jan 2009 10:41:58 +0100

> David Miller wrote:
> > From: Roel Kluin <roel.kluin@gmail.com>
> > Date: Sun, 18 Jan 2009 23:57:43 +0100
> > 
> >> both pdata->mdc and pdata->mdio are unsigned. Notice a negative
> >> return value.
> > 
> > You left the unsigned tests in there:
> > 
> >>  	if (pdata->mdc < 0 || pdata->mdio < 0)
> >>  		goto out_free;
> > 
> > Please remove them.
> 
> thanks, here it is, also with a signoff:
> 
> both pdata->mdc and pdata->mdio are unsigned. Notice a negative
> return value.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied, thanks Roel.
