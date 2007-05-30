From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] defxx: Fix the handling of ioremap() failures
Date: Wed, 30 May 2007 09:53:23 -0400
Message-ID: <465D81D3.7040609@garzik.org>
References: <Pine.LNX.4.64N.0705291508300.14456@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33841 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751974AbXE3Nx1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 09:53:27 -0400
In-Reply-To: <Pine.LNX.4.64N.0705291508300.14456@blysk.ds.pg.gda.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Maciej W. Rozycki wrote:
>  If ioremap_nocache() is unfortunate enough to fail, the error code is not 
> set correctly leading to a false success from dfx_register().  This change 
> fixes the problem.
> 
> Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>

applied


