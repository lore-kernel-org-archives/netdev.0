From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH]: e1000: Janitor: Use #defined values for literals
Date: Tue, 27 Jun 2006 12:32:24 -0500
Message-ID: <20060627173224.GA31770@austin.ibm.com>
References: <20060623163624.GM8866@austin.ibm.com> <449C49F9.6090005@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, john.ronciak@intel.com,
	jesse.brandeburg@intel.com, jeffrey.t.kirsher@intel.com,
	"Zhang, Yanmin" <yanmin.zhang@intel.com>,
	Jeff Garzik <jgarzik@pobox.com>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:40102 "EHLO
	e32.co.us.ibm.com") by vger.kernel.org with ESMTP id S1161223AbWF0Rc0
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 13:32:26 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
Content-Disposition: inline
In-Reply-To: <449C49F9.6090005@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 23, 2006 at 01:07:21PM -0700, Auke Kok wrote:
> Linas Vepstas wrote:
> >Minor janitorial patch: use #defines for literal values.
> >+	pci_enable_wake(pdev, PCI_D3hot, 0);
> >+	pci_enable_wake(pdev, PCI_D3cold, 0);
> 
> I Acked this but that's silly - the patches sent yesterday already change 
> the code above and this patch is no longer needed (thanks Jesse for 
> spotting this).
> 
> This patch would conflict with them so please don't apply.

Maybe there's a backlog in the queue, but I not this is not 
yet in 2.6.17-mm3 

--linas

