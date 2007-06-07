From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2 driver reports WoL not supported when it actually
 works
Date: Thu, 7 Jun 2007 00:30:31 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC0940168@nt-irva-0751.brcm.ad.broadcom.com>
References: <20070606164350.7b650d5e@mann-lx.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: "Tim Mann" <mann@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1972 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754635AbXFGHat convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 03:30:49 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070606164350.7b650d5e@mann-lx.eng.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tim Mann wrote:

> Hi, Michael.  We have some IBM blades with a BCM5708-based dual-port
> NIC that the bnx2 driver reports as not supporting wake-on-LAN.
> (Ethtool says "Supports Wake-on: d".)  However, IBM says that WoL is
> supported by these NICs, and in fact when I tried putting the blade
> into soft-off and sending a magic packet to it, it did wake up!  I
> tried both ports, and they both worked.
> 

In this case, the driver is not supporting WoL because Serdes chips
draw more than the maximum current allowed under Aux. power.  The
blades generally will have no problem supporting WoL because the
motherboard is designed to support the extra power requirements of
the Serdes chips under Aux. power.

The driver will have to get some information from NVRAM to decide
whether Serdes WoL can be supported.  This should be doable and
I'll look into it.

Thanks.



