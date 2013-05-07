From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [PATCH net 2/4] be2net: Fix ethtool get drvinfo
Date: Tue, 7 May 2013 16:21:37 +0100
Message-ID: <1367940097.2782.8.camel@bwh-desktop.uk.solarflarecom.com>
References: <6ecf8164-2cef-4a5a-9a18-5c1ba2c41f7c@CMEXHTCAS2.ad.emulex.com>
	 <1367328131.5106.62.camel@deadeye.wl.decadent.org.uk>
	 <5d52789a-ec61-4c49-b169-5c1535e2368e@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Purayil, Kalesh" <Kalesh.Purayil@Emulex.Com>
To: "Kotur, Somnath" <Somnath.Kotur@Emulex.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:21640 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756600Ab3EGPVm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 11:21:42 -0400
In-Reply-To: <5d52789a-ec61-4c49-b169-5c1535e2368e@CMEXHTCAS1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-05-07 at 06:27 +0000, Kotur, Somnath wrote:
> > Although I documented that as being possible in ethtool.h, that was only
> > because of one particular caller that has since been removed (commit
> > e52ac3398c3d 'net: Use device model to get driver name in
> > skb_gso_segment()').  So unless I missed another case, you could change the
> > documentation.
> > 
> Ben, pls correct me if my understanding is wrong here , but I do see
> one more case where it might have been missed and that 
> Is in the function - is_cnic_dev() in cnic.c , I believe this was the
> case that we were trying to work-around with.

It's called from a netdev notifier, which holds the RTNL lock.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
