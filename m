From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [net 3/8] ixgbe: fix vf lookup
Date: Wed, 8 Feb 2012 23:39:02 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A0702F86227@ORSMSX106.amr.corp.intel.com>
References: <1328693798-27323-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1328693798-27323-4-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120208.183314.265645315647132912.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:57788 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754853Ab2BHXjV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 18:39:21 -0500
In-Reply-To: <20120208.183314.265645315647132912.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, February 08, 2012 3:33 PM
> To: Kirsher, Jeffrey T
> Cc: Rose, Gregory V; netdev@vger.kernel.org; gospo@redhat.com;
> sassmann@redhat.com; stable@vger.kernel.org
> Subject: Re: [net 3/8] ixgbe: fix vf lookup
> 
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Wed,  8 Feb 2012 01:36:33 -0800
> 
> > -		if (pvfdev->devfn == vf_devfn)
> > +		if (pvfdev->devfn == vf_devfn &&
> > +				(pvfdev->bus->number >= pdev->bus->number))
> 
> Come on.... do you look at these patches at all?
> 
> I don't think you did, because this kind of code formatting stuff
> sticks out like a sore thumb.

I'll fix it.

- Greg
