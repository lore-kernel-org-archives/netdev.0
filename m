From: "Chris Friesen" <cfriesen@nortel.com>
Subject: question on netlink_overrun()
Date: Wed, 04 Mar 2009 19:18:41 -0600
Message-ID: <49AF2871.10804@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kp.nortel.com ([47.140.192.56]:47278 "EHLO
	zrtps0kp.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751328AbZCEBxh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 20:53:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Currently we set netlink_overrun() on the socket in both the unicast and 
broadcast paths.  If I understand things correctly this should result in 
the receiver getting ENOBUFS the next time they try a socket-related 
syscall.

However, in the netlink_dump() code we don't call it--was this an 
oversight or an intentional design decision?

I have a userspace app that would like to know if it ran out of buffer 
space in the receive socket (and hence lost some packets) while dumping 
SA information in xfrm_user_rcv_msg().

Thanks,

Chris
