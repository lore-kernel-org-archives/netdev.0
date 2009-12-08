From: Jon Loeliger <jdl@bigfootnetworks.com>
Subject: Using netlink for intra-kernel requests?
Date: Tue, 08 Dec 2009 15:42:26 -0600
Message-ID: <1260308546.29528.27.camel@jdl-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from L01SLCSMTP01.calltower.com ([69.4.184.248]:27018 "EHLO
	L01SLCSMTP01.calltower.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966576AbZLHV7O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 16:59:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Guys,

I am looking for some documentation or an example that explains
how to use the Netlink interface to generate a message, send it,
and receive and process a reply all within the kernel.  I can
find lots of examples how to do this from user space, and even
the RFC shirks off talking about intra-kernel netlink messages.

Specifically, I would like to generate a RTM_GETQDISC message,
send it to the RTNL socket, and set up a listner to receive a reply.

I think I can create the netlink message in an skb.  And I think
I should call rtnl_notify() to deliver it (on the init_net namespace
with pid == 0, right?).  But where or how do I establish a means to
get the response?

I tried to read through some of the similar routing bits, but
even they confess that they "should use netlink", but then doesn't.

I feel like I am missing or don't know where to find the
documentation for the intra-kernel netlink messaging.

Thanks,
jdl


