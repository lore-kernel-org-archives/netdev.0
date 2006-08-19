From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 15/41] ni52 section fix
Date: Sat, 19 Aug 2006 17:39:39 -0400
Message-ID: <44E7851B.6050801@garzik.org>
References: <200608150600.k7F605Jd012645@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:17568 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751821AbWHSVjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Aug 2006 17:39:42 -0400
To: akpm@osdl.org
In-Reply-To: <200608150600.k7F605Jd012645@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> From: Andrew Morton <akpm@osdl.org>
> 
> WARNING: drivers/net/ni52.o - Section mismatch: reference to .init.text:ni52_probe from .text between 'init_module' (at offset 0x997) and 'ni52_close'
> WARNING: drivers/net/ni65.o - Section mismatch: reference to .init.text:ni65_probe from .text between 'init_module' (at offset 0x54a) and 'ni65_stop_start'
> 
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

I'm applying these, but in the future please collapse a series of 
one-liner changes, all of which apply the same change to different 
drivers, into just a few patches.  Or even just one patch.

	Jeff



