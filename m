From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] PCI Error Recovery: e1000 network device driver
Date: Fri, 24 Mar 2006 18:22:06 -0800
Message-ID: <20060325022206.GA6361@kroah.com>
References: <20060324220002.GC26137@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, john.ronciak@intel.com,
	jesse.brandeburg@intel.com, jeffrey.t.kirsher@intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz, linuxppc-dev@ozlabs.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751655AbWCYCWh@vger.kernel.org>
To: Linas Vepstas <linas@austin.ibm.com>
Content-Disposition: inline
In-Reply-To: <20060324220002.GC26137@austin.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 24, 2006 at 04:00:02PM -0600, Linas Vepstas wrote:
> +	/* Perform card reset only on one instance of the card */
> +	if(0 != PCI_FUNC (pdev->devfn))
> +		return PCI_ERS_RESULT_RECOVERED;

You seem to have forgotton to put a ' ' after the 'if' in a number of
different places in this patch.  Also the (0 != foo) form is a bit
different from the traditional kernel coding style.

> +	switch(adapter->hw.mac_type) {

And here too.

Remember, "if" and "switch" are not functions...

thanks,

greg k-h
