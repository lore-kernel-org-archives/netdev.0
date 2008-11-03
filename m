From: Chuck Lever <chuck.lever@oracle.com>
Subject: ipv6_addr_type() and mapped IPv4 loopback
Date: Mon, 3 Nov 2008 18:01:48 -0500
Message-ID: <06930890-5BC3-4BE2-97CC-B3F6DF33B794@oracle.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:35001 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753795AbYKCXBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 18:01:52 -0500
Received: from agmgw1.us.oracle.com (agmgw1.us.oracle.com [152.68.180.212])
	by agminet01.oracle.com (Switch-3.2.4/Switch-3.2.4) with ESMTP id mA3N1oqt013054
	for <netdev@vger.kernel.org>; Mon, 3 Nov 2008 17:01:50 -0600
Received: from acsmt707.oracle.com (acsmt707.oracle.com [141.146.40.85])
	by agmgw1.us.oracle.com (Switch-3.2.0/Switch-3.2.0) with ESMTP id mA3N1ncN010990
	for <netdev@vger.kernel.org>; Mon, 3 Nov 2008 16:01:49 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The __ipv6_addr_type() function does not recognize the mapped IPv4  
loopback address:

    ::ffff:7f00:0001

as type IPV6_ADDR_LOOPBACK.  Is this intentional?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
