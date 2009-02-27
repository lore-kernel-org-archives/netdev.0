From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] gianfar : Do right check on num_txbdfree
Date: Fri, 27 Feb 2009 03:18:57 -0800 (PST)
Message-ID: <20090227.031857.240013447.davem@davemloft.net>
References: <20090226.020318.50178027.davem@davemloft.net>
	<49A66E2D.3060204@arvoo.nl>
	<2acbd3e40902261407w7e92dbe0u4dd008b3e6b239a2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rini@arvoo.nl, Linuxppc-dev@ozlabs.org, afleming@freescale.com,
	netdev@vger.kernel.org
To: afleming@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46858
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753219AbZB0LTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 06:19:15 -0500
In-Reply-To: <2acbd3e40902261407w7e92dbe0u4dd008b3e6b239a2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@gmail.com>
Date: Thu, 26 Feb 2009 16:07:16 -0600

> On Thu, Feb 26, 2009 at 4:25 AM, Rini van Zetten <rini@arvoo.nl> wrote:
> > This patch fixes a wrong check on num_txbdfree. It could lead to
> > num_txbdfree become nagative.
> > Result was that the gianfar stops sending data.
> >
> > Changes from first version :
> > - removed a space between parens (David Millers comment)
> > - full email address in signed off line
> >
> >
> > Signed-off-by: Rini van Zetten <rini@arvoo.nl>
> 
> Good catch.  Does this solve the bug you reported earlier?
> 
> Acked-by: Andy Fleming <afleming@freescale.com>

Applied, thanks.
