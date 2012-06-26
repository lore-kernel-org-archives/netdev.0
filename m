From: Greg Rose <gregory.v.rose@intel.com>
Subject: Re: New commands to configure IOV features
Date: Tue, 26 Jun 2012 10:19:03 -0700
Message-ID: <20120626101903.0000791c@unknown>
References: <4FA7AF62.8000405@broadcom.com>
	<20120507081634.000003f8.gregory.v.rose@intel.com>
	<4FE9A963.7020602@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:46841 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758499Ab2FZRTb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jun 2012 13:19:31 -0400
In-Reply-To: <4FE9A963.7020602@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Jun 2012 15:21:55 +0300
Yuval Mintz <yuvalmin@broadcom.com> wrote:

> On 05/07/2012 06:16 PM, Greg Rose wrote:
> 
> > On Mon, 7 May 2012 14:17:54 +0300
> > Yuval Mintz <yuvalmin@broadcom.com> wrote:
> > 
> >> I've tried to figure out if there was a standard interface
> >> (ethtool/iproute) through which a user could configure the number
> >> of vfs in his system.
> >>
> >> I've seen the RFC suggested in
> >> http://markmail.org/thread/qblfcv7zbxsxp7q6, and
> >> http://markmail.org/thread/fw54dcppmxuxoe6n, but failed to see any
> >> later references to it (commits or further discussion on this
> >> topic).
> >>
> >> How exactly are things standing with these RFCs? Were they
> >> abandoned?
> > 
> > The only way to configure the number of VFs continues to be through
> > the max_vfs module parameter.  I've got a patch to do it through
> > ethtool sitting on the back burner but due to other requirements of
> > my day job I've not been able to work on it since last fall.
> > 
> > - Greg
> 
> 
> Hi Ben,
> 
> If I want to pick the RFCs and add support for configuring the number
> of VFs - do you think ethtool's the right place for such added
> support?
> 
> I'm asking since as far as I can see, ethtool (today) doesn't contain
> any features related to virtual functions.

I think a PCI utility tool would be better, SR-IOV is not limited to
network devices.  That's one of the reasons I dropped the RFC.  I
haven't gotten back to the idea since then due to my day job keeping me
pretty busy.

- Greg
