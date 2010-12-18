From: Jon Mason <jon.mason@exar.com>
Subject: Re: "x86: allocate space within a region top-down" causes bar0
 access issue
Date: Sat, 18 Dec 2010 16:01:09 -0600
Message-ID: <20101218220109.GE7676@exar.com>
References: <20101217194457.GA4470@exar.com>
 <20101217114721.04eafeca@jbarnes-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Bjorn Helgaas <bjorn.helgaas@hp.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.exar.com ([204.154.183.83]:1990 "EHLO smtp1.exar.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932284Ab0LRWBM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Dec 2010 17:01:12 -0500
Content-Disposition: inline
In-Reply-To: <20101217114721.04eafeca@jbarnes-desktop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 17, 2010 at 11:47:21AM -0800, Jesse Barnes wrote:
> On Fri, 17 Dec 2010 13:44:58 -0600
> Jon Mason <jon.mason@exar.com> wrote:
>
> > The following patch is causing problem with the vxge driver/adapter on
> > HP x86-64 systems. Reads to bar0 to return 0xffffffffffffffff instead
> > of their intended value.  This prevents the vxge module from loading
> > by failing sanity checks in the driver for certain values in bar0.  We
> > are not seeing any issues with this patch on non-HP systems in our
> > lab.
> >
> > Can this patch be removed from 2.6.37 until a better solution can be
> > found?
>
> Can you try my for-linus branch and see if the problem still exists
> there?  It's at
> git://git.kernel.org/pub/scm/linux/kernel/git/jbarnes/pci-2.6.git.

The for-linus branch does NOT have the issue
The master branch does have the issue

Thanks,
Jon

>
> Thanks,
> --
> Jesse Barnes, Intel Open Source Technology Center

The information and any attached documents contained in this message
may be confidential and/or legally privileged.  The message is
intended solely for the addressee(s).  If you are not the intended
recipient, you are hereby notified that any use, dissemination, or
reproduction is strictly prohibited and may be unlawful.  If you are
not the intended recipient, please contact the sender immediately by
return e-mail and destroy all copies of the original message.
