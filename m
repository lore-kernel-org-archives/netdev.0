From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: Re: [PATCH] 3c59x: consolidate error cleanup in vortex_init_one()
Date: Mon, 10 Jun 2013 13:57:09 +0200
Message-ID: <20130610115709.GA30712@slnx.de>
References: <201306100016.52820.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from master.slnx.de ([144.76.43.239]:40997 "EHLO master.slnx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753549Ab3FJMFX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jun 2013 08:05:23 -0400
Content-Disposition: inline
In-Reply-To: <201306100016.52820.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 10, 2013 at 12:16:52AM +0400, Sergei Shtylyov wrote:
> The PCI driver's probe() method  duplicates the error cleanup code each time it
> has to do error exit. Consolidate the error cleanup code  in  one place and use
> *goto* to jump to the right places.
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 

Looks ok,

Acked-by: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
