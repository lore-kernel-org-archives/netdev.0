From: "Parikh, Neerav" <neerav.parikh@intel.com>
Subject: RE: [net-next 05/11] netdev: FCoE: Add new ndo_get_fcoe_hbainfo()
 call
Date: Tue, 3 Jan 2012 20:53:00 +0000
Message-ID: <739353123C992A4C8800D77E20942590240B7DC8@ORSMSX101.amr.corp.intel.com>
References: <1325618356-2655-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1325618356-2655-6-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120103.150742.289215241240567940.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:36472 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754696Ab2ACUxC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 15:53:02 -0500
In-Reply-To: <20120103.150742.289215241240567940.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, January 03, 2012 12:08 PM
> To: Kirsher, Jeffrey T
> Cc: Parikh, Neerav; netdev@vger.kernel.org; gospo@redhat.com;
> sassmann@redhat.com
> Subject: Re: [net-next 05/11] netdev: FCoE: Add new
> ndo_get_fcoe_hbainfo() call
> 
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Tue,  3 Jan 2012 11:19:10 -0800
> 
> > +	int			(*ndo_fcoe_get_hbainfo)(struct net_device *dev,
> > +					struct netdev_fcoe_hbainfo *hbainfo);
> 
> Please line up the second line's argument correctly, it should be:
> 
I was just trying to make checkpatch.pl happy as the line went beyond
80 character limit.

> > +	int			(*ndo_fcoe_get_hbainfo)(struct net_device *dev,
> > +							struct netdev_fcoe_hbainfo
> *hbainfo);
> 
> Thanks.
