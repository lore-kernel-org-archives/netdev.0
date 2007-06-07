From: Baruch Even <baruch@ev-en.org>
Subject: Multicast and hardware checksum
Date: Fri, 08 Jun 2007 01:33:14 +0300
Message-ID: <466887AA.800@ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-123-59-149.central.biz.rr.com ([24.123.59.149]:52581
	"EHLO galon.ev-en.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935470AbXFGWdz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 18:33:55 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I have a machine on which I have an applications that sends multicast 
through eth interface with hardware tx checksum enabled. On the same 
machine I have mrouted running that routes the multicast traffic to a 
set of ppp interfaces. The packets that are received by the client have 
their checksum fixed on some number which is incorrect. If I disable tx 
checksum on the eth device the packets arrive with the proper checksum.

I still haven't followed the code paths to see how to fix this, maybe 
someone knows the relevant code and can find it faster.

Baruch
