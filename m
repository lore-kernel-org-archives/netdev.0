From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: New commands to configure IOV features
Date: Mon, 9 Jul 2012 19:39:15 +0100
Message-ID: <1341859155.2535.43.camel@bwh-desktop.uk.solarflarecom.com>
References: <4FA7AF62.8000405@broadcom.com>
	 <20120507081634.000003f8.gregory.v.rose@intel.com>
	 <4FE9A963.7020602@broadcom.com> <20120626101903.0000791c@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yuval Mintz <yuvalmin@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Greg Rose <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:38370 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752707Ab2GISjT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 14:39:19 -0400
In-Reply-To: <20120626101903.0000791c@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-26 at 10:19 -0700, Greg Rose wrote:
> On Tue, 26 Jun 2012 15:21:55 +0300
> Yuval Mintz <yuvalmin@broadcom.com> wrote:
> 
> > On 05/07/2012 06:16 PM, Greg Rose wrote:
> > 
> > > On Mon, 7 May 2012 14:17:54 +0300
> > > Yuval Mintz <yuvalmin@broadcom.com> wrote:
> > > 
> > >> I've tried to figure out if there was a standard interface
> > >> (ethtool/iproute) through which a user could configure the number
> > >> of vfs in his system.
> > >>
> > >> I've seen the RFC suggested in
> > >> http://markmail.org/thread/qblfcv7zbxsxp7q6, and
> > >> http://markmail.org/thread/fw54dcppmxuxoe6n, but failed to see any
> > >> later references to it (commits or further discussion on this
> > >> topic).
> > >>
> > >> How exactly are things standing with these RFCs? Were they
> > >> abandoned?
> > > 
> > > The only way to configure the number of VFs continues to be through
> > > the max_vfs module parameter.  I've got a patch to do it through
> > > ethtool sitting on the back burner but due to other requirements of
> > > my day job I've not been able to work on it since last fall.
> > > 
> > > - Greg
> > 
> > 
> > Hi Ben,
> > 
> > If I want to pick the RFCs and add support for configuring the number
> > of VFs - do you think ethtool's the right place for such added
> > support?
> > 
> > I'm asking since as far as I can see, ethtool (today) doesn't contain
> > any features related to virtual functions.
> 
> I think a PCI utility tool would be better, SR-IOV is not limited to
> network devices.  That's one of the reasons I dropped the RFC.  I
> haven't gotten back to the idea since then due to my day job keeping me
> pretty busy.

For what it's worth, I agree with this.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
