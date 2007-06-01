From: Jeff Garzik <jeff@garzik.org>
Subject: Re: ETHTOOL_GSET IOCTL on GigE links
Date: Fri, 01 Jun 2007 19:04:36 -0400
Message-ID: <4660A604.4080701@garzik.org>
References: <46F9780F64AE9945815725F4C0C72CB80302625D@hq-exch-1.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Jeff Haran <jharan@Brocade.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56900 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752534AbXFAXEq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jun 2007 19:04:46 -0400
In-Reply-To: <46F9780F64AE9945815725F4C0C72CB80302625D@hq-exch-1.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Haran wrote:
> OK, but my question remains. In the case where a device supports one set
> of speeds via autonegotiation and another set via forcing, how does one
> tell which speeds can be forced and which can be autonegotiated?

The interface does not currently support such enumeration.

You can certainly attempt forcing a speed, and see what happens.  The 
driver will either (a) work, (b) refuse and give you an error message, 
or (c) present you with a situation that requires filing a driver bug 
report :)

	Jeff


