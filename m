From: "Naveen B N (nbn)" <nbn@cisco.com>
Subject: protect raw sockets
Date: Thu, 18 Aug 2011 13:45:58 +0530
Message-ID: <A2354B6A9F807641B21EEABD666ECEEA011AFCE2@XMB-BGL-416.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ams-iport-1.cisco.com ([144.254.224.140]:43216 "EHLO
	ams-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755328Ab1HRIQP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2011 04:16:15 -0400
Received: from xbh-bgl-411.cisco.com (xbh-bgl-411.cisco.com [72.163.129.201])
	by bgl-core-1.cisco.com (8.14.3/8.14.3) with ESMTP id p7I8FXrB006052
	for <netdev@vger.kernel.org>; Thu, 18 Aug 2011 08:16:13 GMT
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,
Is there a way to enforce IPsec protection for packets sent from
application using RAW_SOCKET.

My analysis is to add a code at the raw_sendmsg() & raw_v4_input() to
call xfrm_policy_check() ..
Is it a good method to proceed or is there a better and smart way to
achieve this .

Hoping for some guide lines ..

Thanks in advance ..

Thanks and Regards
Naveen
