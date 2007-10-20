From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 5/7] pci: Export the pci_restore_msi_state()
 function
Date: Fri, 19 Oct 2007 17:36:17 -0700
Message-ID: <1192840577.5369.9.camel@dell>
References: <1192829817.22064.559.camel@teletran1>
 <20071019232926.GL29903@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Matt Carlson" <mcarlson@broadcom.com>,
	"David Miller" <davem@davemloft.net>,
	"netdev" <netdev@vger.kernel.org>,
	linux-pci@atrey.karlin.mff.cuni.cz
To: linas@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1379 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758829AbXJSXjZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 19:39:25 -0400
In-Reply-To: <20071019232926.GL29903@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-10-19 at 18:29 -0500, linas@austin.ibm.com wrote:
> On Fri, Oct 19, 2007 at 02:36:56PM -0700, Matt Carlson wrote:
> > This patch exports the pci_restore_msi_state() function.  This function
> > is needed to restore the MSI state during PCI error recovery.
> > 
> > Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> > Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> 
> Davem,
> 
> This patch is generically needed for recovery from PCI errors, 
> and not just the tg3 that Matt is working on.
> 
> Matt, there are also several msi-related bugs in the pseries
> architecture implementation, those patches will go out to 
> Paul Mackerras seperately. I was hoping today ... but things 
> came up. One little iddy-biddy problem is that the pseries
> is not actually *saving* the msi state, and so, ahem, the 
> restore isn't quite working out either. I'm still trying
> to navigate around that.
> 
Linas, the MSI state is saved automatically when the driver calls
pci_enable_msi(), so it doesn't need to be saved by pseries code.

