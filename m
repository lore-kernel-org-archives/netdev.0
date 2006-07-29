From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [stable] [PATCH] e1000: add forgotten PCI ID for supported device
Date: Fri, 28 Jul 2006 17:04:49 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.63.0607281659480.2660@jbrandeb-desk.amr.corp.intel.com>
References: <44CA8A59.40002@intel.com> <20060728231837.GA2109@kroah.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, stable@kernel.org,
	NetDev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:49536 "EHLO
	fmsmga101-1.fm.intel.com") by vger.kernel.org with ESMTP
	id S1751702AbWG2AEx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 20:04:53 -0400
To: Greg KH <greg@kroah.com>
In-Reply-To: <20060728231837.GA2109@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 28 Jul 2006, Greg KH wrote:
> On Fri, Jul 28, 2006 at 03:06:17PM -0700, Auke Kok wrote:
> >
> > The Intel(R) PRO/1000 82572EI card is fully supported by 7.0.33-k2 and
> > onward. Add the device ID so this card works with 2.6.17.y onward. This
> > device ID was accidentally omitted.
> 
> Sorry, but we don't add new device support in the -stable kernel tree,
> it's "bugfixes only."

In this case I believe it to be a bug in our code, instead of adding new 
support.  The driver code supports other device IDs for this same chip. 

The kernel driver advertises through our probe table and in our readme 
that we support this device (code is in e1000_main.c) but we don't load on 
it correctly due to an error when we submitted the patches (e1000_hw.c/h).

Patch is very simple and low risk, but it is your call.

Thanks,
  Jesse
