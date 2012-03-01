From: <Ajit.Khaparde@Emulex.Com>
Subject: RE: [RFC net-next 1/2] if_link : add support for VF privileges
Date: Thu, 1 Mar 2012 10:53:23 -0800
Message-ID: <49395329523DD64492581B505F80C86D5BDD08F6D8@EXMAIL.ad.emulex.com>
References: <20120214192627.GA14163@akhaparde-VBox>
	<1329261897.2443.60.camel@bwh-desktop>
	<49395329523DD64492581B505F80C86D5BDCF681FD@EXMAIL.ad.emulex.com>
 <20120221.170441.1552294498786802979.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <bhutchings@solarflare.com>, <shemminger@linux-foundation.org>,
	<netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:30244 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751024Ab2CASxo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 13:53:44 -0500
In-Reply-To: <20120221.170441.1552294498786802979.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, February 21, 2012 4:05 PM
> To: Khaparde, Ajit
> Cc: bhutchings@solarflare.com; shemminger@linux-foundation.org;
> netdev@vger.kernel.org
> Subject: Re: [RFC net-next 1/2] if_link : add support for VF privileges
> 
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

Since different hardware devices can have different capabilities this possibility exists.
Do you suggest indicating the individual capabilities in the bit mask rather than just a single bit?
That way every VF driver will get to indicate its capabilities.
