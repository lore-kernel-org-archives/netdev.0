From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] phylib: Add support for the LXT973 phy.
Date: Wed, 2 Jun 2010 15:07:59 +0200
Message-ID: <20100602130759.GA20464@riccoc20.at.omicron.at>
References: <20100531130932.GA15845@riccoc20.at.omicron.at>
 <AANLkTilKJVZiKLRUlL7AeaqSnlAs2u5sTW7o2vfvEKns@mail.gmail.com>
 <20100602125527.GA20396@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andy Fleming <afleming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:59020 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756483Ab0FBNH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 09:07:29 -0400
Received: by fg-out-1718.google.com with SMTP id l26so1644616fgb.1
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 06:07:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100602125527.GA20396@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 02, 2010 at 02:55:27PM +0200, Richard Cochran wrote:
> On Tue, Jun 01, 2010 at 05:39:22PM -0500, Andy Fleming wrote:
> > Also, is this erratum true for all lxt973 models, or is it fixed in
> > some revisions?
> 
> The documentation http://www.cortina-systems.com/products/download/266
> says, "Status: This erratum has been previously fixed." However, I
> could not find a reference to when this was fixed.

In any case, the PHY only supports 100 Mbps when in fiber mode, so the
fix is always safe to use.

Richard
