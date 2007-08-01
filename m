From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [RFC][BNX2X]: New driver for Broadcom 10Gb Ethernet.
Date: Wed, 01 Aug 2007 15:28:18 -0700
Message-ID: <adaodhq6gal.fsf@cisco.com>
References: <1185957077.5552.22.camel@dell> <200708020006.13457.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael Chan" <mchan@broadcom.com>, davem@davemloft.net,
	jeff@garzik.org, netdev@vger.kernel.org, eliezert@broadcom.com,
	lusinsky@broadcom.com, eilong@broadcom.com
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:57638 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753940AbXHAW2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2007 18:28:20 -0400
In-Reply-To: <200708020006.13457.mb@bu3sch.de> (Michael Buesch's message of "Thu, 2 Aug 2007 00:06:12 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > > +	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_5710,
 > > +		PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM5710 },

FWIW, this could be neater as

	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_5710), BCM5710 }

 - R.
