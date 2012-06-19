From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [RFC net-next 01/14] Add Default
Date: Tue, 19 Jun 2012 20:41:18 +0300
Message-ID: <1340127678.2486.18.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
 <1340118848-30978-2-git-send-email-yuvalmin@broadcom.com>
 <4FE0AABE.4070100@intel.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Yuval Mintz" <yuvalmin@broadcom.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: "Alexander Duyck" <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3685 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751049Ab2FSRlg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 13:41:36 -0400
In-Reply-To: <4FE0AABE.4070100@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-19 at 09:37 -0700, Alexander Duyck wrote:
> On 06/19/2012 08:13 AM, Yuval Mintz wrote:
> > Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> > Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> > ---
> >  include/linux/etherdevice.h |    5 ++++-
> >  1 files changed, 4 insertions(+), 1 deletions(-)
> >
> > diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
> > index 3d406e0..bb1ecaf 100644
> > --- a/include/linux/etherdevice.h
> > +++ b/include/linux/etherdevice.h
> > @@ -44,7 +44,10 @@ extern int eth_mac_addr(struct net_device *dev, void *p);
> >  extern int eth_change_mtu(struct net_device *dev, int new_mtu);
> >  extern int eth_validate_addr(struct net_device *dev);
> >  
> > -
> > +/* The maximal number of RSS queues a driver should have unless configured
> > + * so explicitly.
> > + */
> > +#define DEFAULT_MAX_NUM_RSS_QUEUES (8)
> >  
> >  extern struct net_device *alloc_etherdev_mqs(int sizeof_priv, unsigned int txqs,
> >  					    unsigned int rxqs);
> I'm not a big fan of just having this as a fixed define in the code.  It
> seems like it would make much more sense to have this in the Kconfig
> somewhere as a range value if you plan on making this changeable in the
> future.

My original suggestion was a kernel command line parameter, but Dave was
less than enthusiastic. If you will follow the original thread, you can
probably understand why I decided to adopt Dave's constant approach
without suggesting Kconfig:
http://marc.info/?l=linux-netdev&m=133992386010982&w=2

However, 8 is not a holy number - I'm open for suggestions.

Thanks,
Eilon
