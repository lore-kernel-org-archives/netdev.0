From: Jeff Garzik <jgarzik@redhat.com>
Subject: Re: ethtool: missing implementation of n_priv_flags
Date: Thu, 28 Oct 2010 17:53:59 -0400
Message-ID: <20101028215358.GB9421@shell.devel.redhat.com>
References: <F169D4F5E1F1974DBFAFABF47F60C10AA5E60671@orsmsx507.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12770 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758175Ab0J1VyB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Oct 2010 17:54:01 -0400
Content-Disposition: inline
In-Reply-To: <F169D4F5E1F1974DBFAFABF47F60C10AA5E60671@orsmsx507.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 28, 2010 at 01:34:34PM -0700, Brandeburg, Jesse wrote:
> Was just looking at implementing the driver private flags to add a new feature to 
> a driver.
> 
> It appears that nothing in the core ethtool.c ever accesses or prints n_priv_flags, 
> even if a driver assigns it (which none in the kernel currently do)
> 
> Is this just an oversight?

It was waiting for the first user, basically...  I created an example
kernel patch for one Intel driver, but you guys didn't seem interested
in it at the time.  Glad to see it's getting some attention.

	Jeff



