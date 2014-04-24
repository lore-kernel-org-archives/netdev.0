From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: [net-next 07/13] igb: Cleanups to fix line length warnings
Date: Thu, 24 Apr 2014 17:02:13 +0000
Message-ID: <9BBC4E0CF881AA4299206E2E1412B6264FB055F4@ORSMSX102.amr.corp.intel.com>
References: <1398335460-4283-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1398335460-4283-8-git-send-email-jeffrey.t.kirsher@intel.com>
 <20140424.124003.1781449604554546212.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:1796 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754038AbaDXRDA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 13:03:00 -0400
In-Reply-To: <20140424.124003.1781449604554546212.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of David Miller
> Sent: Thursday, April 24, 2014 9:40 AM
> To: Kirsher, Jeffrey T
> Cc: Wyborny, Carolyn; netdev@vger.kernel.org; gospo@redhat.com;
> sassmann@redhat.com
> Subject: Re: [net-next 07/13] igb: Cleanups to fix line length warnings
> 
[..]
> >  	/* Enable all RX queues before testing. */
> > -	{ E1000_RXDCTL(0), 0x100, 4,  WRITE_NO_TEST, 0,
> E1000_RXDCTL_QUEUE_ENABLE },
> > -	{ E1000_RXDCTL(4), 0x40, 12,  WRITE_NO_TEST, 0,
> E1000_RXDCTL_QUEUE_ENABLE },
> > +	{ E1000_RXDCTL(0), 0x100, 4, WRITE_NO_TEST, 0,
> > +
> 	E1000_RXDCTL_QUEUE_ENABLE },
> 
> The second line should start at the same column as E1000_RXDCTL(0) on the
> first line, rather than tabbed all the way to outer-space.

Ok, will fix.

Carolyn Wyborny 
Linux Development 
Networking Division 
Intel Corporation 
