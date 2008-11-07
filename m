From: Roman Chertov <roman@santabarbaralabs.com>
Subject: 2.6.24.7 ipv6 send redirect
Date: Fri, 07 Nov 2008 11:16:16 -0800
Message-ID: <49149400.2060301@santabarbaralabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.196]:61805 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750962AbYKGTQQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Nov 2008 14:16:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
    I need to disable IPv6 ICMP redirect messages.  In the 
/proc/sys/net/ipv4/conf/all/ there is a flag send_redirects which 
disables sending of the redirects in IPv4.  However, this option is not 
present in the /proc/sys/net/ipv6/conf/all/.  Did this option get moved 
to another location?  I would prefer to disable the redirects via a flag 
and want to resort to changing the IPv6 forwarding code as the last measure.

Thanks,

Roman
