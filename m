From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 0/3][IPV6]: remove ifdef in route6 init/fini functions
Date: Fri, 07 Dec 2007 14:13:25 +0100
Message-ID: <20071207131325.332768305@ICON-9-164-138-215.megacenter.de.ibm.com>
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([195.212.29.140]:23938 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753585AbXLGNVD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 08:21:03 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate7.uk.ibm.com (8.13.8/8.13.8) with ESMTP id lB7DL2xk439406
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 13:21:02 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB7DL2iS4235318
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 13:21:02 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB7DKjeT005483
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 13:20:45 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The route6 init function is a little difficult to read because it contains 
a lot of ifdef. The patchset redefines the usual static inline functions when
the code is to be disabled by configuration, so we can call the code without
taking care of the config option in the init function.

-- 
