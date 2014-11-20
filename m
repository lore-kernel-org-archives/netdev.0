From: James Yonan <james@openvpn.net>
Subject: Question on bulk dequeue support in virtual drivers
Date: Thu, 20 Nov 2014 05:39:44 -0700
Message-ID: <546DE110.8060607@openvpn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.yonan.net ([54.244.116.145]:58441 "EHLO mail.yonan.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751894AbaKTMjp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2014 07:39:45 -0500
Received: from Moab.local (c-67-166-32-18.hsd1.co.comcast.net [67.166.32.18])
	(using TLSv1 with cipher ECDHE-RSA-AES128-SHA (128/128 bits))
	(No client certificate requested)
	by mail.yonan.net (Postfix) with ESMTPSA id 211EAC0E5D
	for <netdev@vger.kernel.org>; Thu, 20 Nov 2014 05:39:45 -0700 (MST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consider a tunneling driver that receives packets in ndo_start_xmit, 
encapsulates them in UDP, and forwards via ip_local_out.  The 
ndo_start_xmit implementation can implement bulking by looking at 
skb->xmit_more.  But then how to efficiently transmit the resulting 
bulked list of encapsulated packets via UDP, so that the packets both 
enter and leave the driver in bulked form?  Is there an ip_local_out 
alternative for bulked skb lists?

James
