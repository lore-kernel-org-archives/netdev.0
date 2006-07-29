From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH] e1000: add forgotten PCI ID for supported device
Date: Fri, 28 Jul 2006 17:24:40 -0700
Message-ID: <20060729002440.GA3284@kroah.com>
References: <44CA8A59.40002@intel.com> <20060728231837.GA2109@kroah.com> <Pine.WNT.4.63.0607281659480.2660@jbrandeb-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, stable@kernel.org,
	NetDev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kroah.org ([69.55.234.183]:4801 "EHLO perch.kroah.org")
	by vger.kernel.org with ESMTP id S1161376AbWG2A1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 20:27:41 -0400
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Content-Disposition: inline
In-Reply-To: <Pine.WNT.4.63.0607281659480.2660@jbrandeb-desk.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 28, 2006 at 05:04:49PM -0700, Brandeburg, Jesse wrote:
> On Fri, 28 Jul 2006, Greg KH wrote:
> > On Fri, Jul 28, 2006 at 03:06:17PM -0700, Auke Kok wrote:
> > >
> > > The Intel(R) PRO/1000 82572EI card is fully supported by 7.0.33-k2 and
> > > onward. Add the device ID so this card works with 2.6.17.y onward. This
> > > device ID was accidentally omitted.
> > 
> > Sorry, but we don't add new device support in the -stable kernel tree,
> > it's "bugfixes only."
> 
> In this case I believe it to be a bug in our code, instead of adding new 
> support.  The driver code supports other device IDs for this same chip. 

Heh, that would be a slipery slope, as everyone who adds device ids
feels that it is a "bug" that the driver does not support their device.
If we were to allow this, there would be a _lot_ more -stable patches,
which I don't think is a good thing to have.

> The kernel driver advertises through our probe table and in our readme 
> that we support this device (code is in e1000_main.c) but we don't load on 
> it correctly due to an error when we submitted the patches (e1000_hw.c/h).
> 
> Patch is very simple and low risk, but it is your call.

Sorry, but for now, no.  Users should be able to use the sysfs bind and
new_id interface to add new device support for your driver, if it's
written properly :)

thanks,

greg k-h
