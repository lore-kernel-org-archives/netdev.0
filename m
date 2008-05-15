From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: dead network on JS21 with tg3 driver after flowcontrol
 changes
Date: Thu, 15 May 2008 08:10:16 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC002AABCEE@nt-irva-0751.brcm.ad.broadcom.com>
References: <20080515121340.GA23033@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: "Olaf Hering" <olaf@aepfle.de>,
	"Matthew Carlson" <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2752 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756723AbYEOPKh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 11:10:37 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080515121340.GA23033@aepfle.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Olaf Hering wrote:

> Any ideas how to fix this?
> What info do you need from the system?

Are you using eth0 or eth1?  The dmesg below shows that
link came up on eth1 and IP address from DHCP was received.


> Sending DHCP requests .<6>tg3: eth1: Link is up at 1000 Mbps, 
> full duplex.
> tg3: eth1: Flow control is off for TX and off for RX.
> ., OK
> IP-Config: Got DHCP answer from 10.10.4.97, my address is 10.10.1.110
> IP-Config: Complete:

If you're using eth0 and link did not come up, please provide
mii-tool -vvv eth0.

Thanks.

