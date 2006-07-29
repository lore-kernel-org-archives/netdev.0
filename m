From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [stable] [PATCH] e1000: add forgotten PCI ID for supported device
Date: Fri, 28 Jul 2006 23:19:05 -0400
Message-ID: <20060729031859.GA23779@tuxdriver.com>
References: <44CA8A59.40002@intel.com> <20060728231837.GA2109@kroah.com> <Pine.WNT.4.63.0607281659480.2660@jbrandeb-desk.amr.corp.intel.com> <20060729002440.GA3284@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, stable@kernel.org,
	NetDev <netdev@vger.kernel.org>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:61969 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751317AbWG2DUN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 23:20:13 -0400
To: Greg KH <greg@kroah.com>
Content-Disposition: inline
In-Reply-To: <20060729002440.GA3284@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 28, 2006 at 05:24:40PM -0700, Greg KH wrote:
> On Fri, Jul 28, 2006 at 05:04:49PM -0700, Brandeburg, Jesse wrote:

> > The kernel driver advertises through our probe table and in our readme 
> > that we support this device (code is in e1000_main.c) but we don't load on 
> > it correctly due to an error when we submitted the patches (e1000_hw.c/h).
> > 
> > Patch is very simple and low risk, but it is your call.
> 
> Sorry, but for now, no.  Users should be able to use the sysfs bind and
> new_id interface to add new device support for your driver, if it's
> written properly :)

In this case it isn't an addition to the PCI ID table, but an actual
added check in the code.  You could make the argument that it is a
bug since the PCI ID table says the device is supported, but it won't
work w/o this additional check.

Of course, the "if it's written properly" comment is still valid... :-)

John
-- 
John W. Linville
linville@tuxdriver.com
