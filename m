From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC net-next 1/2] if_link : add support for VF privileges
Date: Tue, 21 Feb 2012 22:43:22 +0000
Message-ID: <1329864202.2689.56.camel@bwh-desktop>
References: <20120214192627.GA14163@akhaparde-VBox>
	 <1329261897.2443.60.camel@bwh-desktop>
	 <49395329523DD64492581B505F80C86D5BDCF681FD@EXMAIL.ad.emulex.com>
	 <20120221.170441.1552294498786802979.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <Ajit.Khaparde@Emulex.Com>, <shemminger@linux-foundation.org>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:61651 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753462Ab2BUWn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 17:43:26 -0500
In-Reply-To: <20120221.170441.1552294498786802979.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-02-21 at 17:04 -0500, David Miller wrote:
> From: <Ajit.Khaparde@Emulex.Com>
> Date: Tue, 21 Feb 2012 14:02:27 -0800
> 
> >> -----Original Message-----
> >> From: Ben Hutchings [mailto:bhutchings@solarflare.com]
> >> Sent: Tuesday, February 14, 2012 5:25 PM
> >> To: Khaparde, Ajit
> >> Cc: davem@davemloft.net; shemminger@linux-foundation.org;
> >> netdev@vger.kernel.org
> >> Subject: Re: [RFC net-next 1/2] if_link : add support for VF privileges
> >> 
> >> On Tue, 2012-02-14 at 13:26 -0600, Ajit Khaparde wrote:
> >> > +enum {
> >> > +	IFLA_VF_PRIVILEGE_DEFAULT = 1,	/* Default privileges */
> >> 
> >> What are the default privileges?  Should existing drivers report that
> >> their VFs have this?
> > Yes. Vendors can decide what privileges they want to grant for VFs by default.
> 
> That's terrible and a very bad interface for users.  It means every system
> can have different defaults, from which we'll derive zero consistency.

Aside from this, my concern is that if we assign privilege flags to
capabilities that VFs normally have now then the value reported where
the driver doesn't support this new operation should not be 0.

(Also, if a privilege is assigned by default, is it really a privilege?
Wouldn't 'capability' or 'permission' be a better term?)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
