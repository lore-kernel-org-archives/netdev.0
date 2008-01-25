From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 00/11][NETNS][IPV6] make a subset of the routing per namespace
Date: Fri, 25 Jan 2008 17:50:08 +0100
Message-ID: <20080125165008.317745745@localhost.localdomain>
Cc: benjamin.thery@bull.net, netdev@vger.kernel.org, den@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:19201 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755628AbYAYRLV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 12:11:21 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m0PHBKCN232926
	for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 17:11:20 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0PHBKF73739754
	for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 17:11:20 GMT
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0PHBGF2001419
	for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 17:11:17 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset makes a subset of the routing to be per
namespace. It takes into account fib tables, garbage
collecting timer, fib rules and route statistics.

The routing per namespace is not complete with this
patchset, so there are some interactions between the init
network namespace and other namespaces, but nothing
critical.

This patchset will be followed by another one which
will complete the routing per namespace. I just don't want
to flood netdev@ with a huge patchset.

-- 
