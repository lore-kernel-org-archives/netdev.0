From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: core: 'ethtool' issue with querying phy
 settings
Date: Mon, 01 Jun 2015 14:46:35 -0700 (PDT)
Message-ID: <20150601.144635.1116373189875340733.davem@davemloft.net>
References: <20150531.171940.1635713770956335110.davem@davemloft.net>
	<1433181931.6319.176.camel@decadent.org.uk>
	<556CD197.8070401@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	bcm-kernel-feedback-list@broadcom.com, rjui@broadcom.com,
	sbranden@broadcom.com, jdzheng@broadcom.com
To: aparames@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <556CD197.8070401@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arun Parameswaran <aparames@broadcom.com>
Date: Mon, 1 Jun 2015 14:41:43 -0700

> It would be nice for the 'ethtool' to be flexible to support querying
> specific PHY irrespective of the net implementation, but that is being
> discussed in the other thread.

Please stop arguing about this, it isn't valid.

Your device is a switch, and therefore needs to be represented properly
with the proper number of net_device objects.

Even more importantly, the ethtool API is established and you cannot
change these semantics without potentially breaking lots of applications
and libraries out there.

Your change is reverted, and I will absolutely not entertain any
attempt to again change the semantics of this ethtool operation.

Thanks.
