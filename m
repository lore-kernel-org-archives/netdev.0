From: Greg Rose <gregory.v.rose@intel.com>
Subject: Re: [0/2] Fix problems with with IFLA_VF_PORTS
Date: Wed, 23 Apr 2014 08:14:15 -0700
Message-ID: <20140423081415.000025af@unknown>
References: <1398237665-26980-1-git-send-email-david@gibson.dropbear.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <ssujith@cisco.com>,
	<neepatel@cisco.com>, <benve@cisco.com>, <davem@davemloft.net>,
	<ben@decadent.org.uk>, <govindarajulu90@gmail.com>
To: David Gibson <david@gibson.dropbear.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:23724 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753866AbaDWPPD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 11:15:03 -0400
In-Reply-To: <1398237665-26980-1-git-send-email-david@gibson.dropbear.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Apr 2014 17:21:03 +1000
David Gibson <david@gibson.dropbear.id.au> wrote:

> I've had a customer encounter a problem with getifaddrs(3) freezing up
> on a system with a Cisco enic device.
> 
> I've discovered that the problem is caused by an enic device with a
> large number of SR-IOV virtual functions overflowing the normal sized
> packet buffer for netlink, leading to interfaces not being reported
> from an RTM_GETLINK request.
> 
> The first patch here just makes the problem easier to locate if it
> occurs again in a different way, by adding a WARN_ON() when we run out
> of room in a netlink packet in this manner.
> 
> The second patch actually fixes the problem, by only reporting
> IFLA_VF_PORTS information when the RTEXT_FILTER_VF flag is specified.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Once you fix a couple of coding style errors mentioned by Jiri then

Acked-by: Greg Rose <gregory.v.rose@intel.com>
