From: "Chris Friesen" <cfriesen@nortel.com>
Subject: question on raw sockets and source IP address validation
Date: Thu, 24 Sep 2009 11:53:39 -0600
Message-ID: <4ABBB223.8090700@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kp.nortel.com ([47.140.192.56]:37222 "EHLO
	zrtps0kp.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752218AbZIXRzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2009 13:55:33 -0400
Received: from zcarhxs1.corp.nortel.com (casmtp.ca.nortel.com [47.129.230.89])
	by zrtps0kp.nortel.com (Switch-2.2.6/Switch-2.2.0) with ESMTP id n8OHtYS01468
	for <netdev@vger.kernel.org>; Thu, 24 Sep 2009 17:55:34 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Normally when sending a packet on a SOCK_RAW socket the source IP
address is validated against the addresses configured on the host.  If
the address isn't configured, the packet isn't sent.

This can be avoided by setting IP_HDRINCL, but then the app needs to
handle all the fragmentation itself.

Is there any way to bypass the source address validation without IP_HDRINCL?

Thanks,

Chris
