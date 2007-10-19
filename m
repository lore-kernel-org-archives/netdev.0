From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 5/7] pci: Export the pci_restore_msi_state() function
Date: Fri, 19 Oct 2007 18:29:26 -0500
Message-ID: <20071019232926.GL29903@austin.ibm.com>
References: <1192829817.22064.559.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz,
	Michael Chan <mchan@broadcom.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:37989 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754241AbXJSX3l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 19:29:41 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9JNTcRH008078
	for <netdev@vger.kernel.org>; Fri, 19 Oct 2007 19:29:38 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9JNTcMo058882
	for <netdev@vger.kernel.org>; Fri, 19 Oct 2007 19:29:38 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9JNTWfR020676
	for <netdev@vger.kernel.org>; Fri, 19 Oct 2007 19:29:32 -0400
Content-Disposition: inline
In-Reply-To: <1192829817.22064.559.camel@teletran1>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 19, 2007 at 02:36:56PM -0700, Matt Carlson wrote:
> This patch exports the pci_restore_msi_state() function.  This function
> is needed to restore the MSI state during PCI error recovery.
> 
> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Davem,

This patch is generically needed for recovery from PCI errors, 
and not just the tg3 that Matt is working on.

Matt, there are also several msi-related bugs in the pseries
architecture implementation, those patches will go out to 
Paul Mackerras seperately. I was hoping today ... but things 
came up. One little iddy-biddy problem is that the pseries
is not actually *saving* the msi state, and so, ahem, the 
restore isn't quite working out either. I'm still trying
to navigate around that.

--linas

