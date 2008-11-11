From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: LRO with ip fragmentation
Date: Tue, 11 Nov 2008 17:13:18 +0100
Message-ID: <4919AF1E.5060500@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Christoph Raisch <raisch@de.ibm.com>,
	jb.billaud@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:47113 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751530AbYKKQNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 11:13:21 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.8/8.13.8) with ESMTP id mABGDJhP475640
	for <netdev@vger.kernel.org>; Tue, 11 Nov 2008 16:13:19 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mABGDJ1k4309036
	for <netdev@vger.kernel.org>; Tue, 11 Nov 2008 16:13:19 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mABGDJ4R022496
	for <netdev@vger.kernel.org>; Tue, 11 Nov 2008 16:13:19 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Jean-Pascal Billaud pointed us to an interesting question:

Currently we do not check in the LRO receive path whether 
TCP packets are ip fragmented. They are aggregated in any 
case which might be wrong. The question is: Is it possible 
that we can get fragmented TCP packets without the tcp stack 
changing the MSS size? How can this be easily intentionally 
provoked for testing (only by using an extra gateway?)?

Regards,

Jan-Bernd

