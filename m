From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [patch] NET: remove support for Davicom 9102 from the Tulip
	driver
Date: Wed, 9 Apr 2008 09:54:39 -0600
Message-ID: <20080409155439.GA1624@colo.lackof.org>
References: <Pine.SOC.4.64.0804031209540.2017@math.ut.ee> <47F69FBE.3020308@garzik.org> <20080404232650.GE27826@colo.lackof.org> <Pine.SOC.4.64.0804071726210.29033@math.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Grundler <grundler@parisc-linux.org>,
	Jeff Garzik <jeff@garzik.org>, cebbert@redhat.com,
	netdev@vger.kernel.org
To: Meelis Roos <mroos@linux.ee>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:38134 "EHLO colo.lackof.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752076AbYDIPyv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Apr 2008 11:54:51 -0400
Content-Disposition: inline
In-Reply-To: <Pine.SOC.4.64.0804071726210.29033@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 07, 2008 at 05:28:03PM +0300, Meelis Roos wrote:
> > jeff and davem already answered the basic SROM/MAC address issue.
> > Patches to fix this are associated with
> > 	http://bugzilla.kernel.org/show_bug.cgi?id=9106
> 
> > >> I happent to have a Sun Fire V100 with 2 Davicom NICs (1282:9102 (rev 
> > >> 31)).
> > >> tulip driver works for them, dmfe doesn't.
> > 
> > This experience doesn't agree with the bug report.
> > Meelis, can you please take a look at the bug report and add comments?
> 
> Comments added.

thanks!
I saw the comments were added but haven't read them yet.

> > We tried (b) but didn't get it working on V100 previously.
> > Several patches are attached to the bug report.
> 
> There was one patch (for getting the MAC from OpenFirmware) but as 
> people reported that the Tx timeouts still happen, I didn't try it. Any 
> reason to try?

Documenting the configuration that does work is the only reason.
I don't think pursueing dmfe is worthwhile if in general tulip driver
is expected to work.

thanks,
grant

> 
> -- 
> Meelis Roos (mroos@linux.ee)
