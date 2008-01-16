From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 0/2][NETNS][DST] pass dst_ops to gc functions and add a netns pointer in it
Date: Wed, 16 Jan 2008 15:54:16 +0100
Message-ID: <20080116145416.844293640@localhost.localdomain>
Cc: netdev@vger.kernel.org, den@openvz.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:23811 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931AbYAPPIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 10:08:35 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m0GF8YLe515016
	for <netdev@vger.kernel.org>; Wed, 16 Jan 2008 15:08:34 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0GF8YFZ5001264
	for <netdev@vger.kernel.org>; Wed, 16 Jan 2008 15:08:34 GMT
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0GF8UW2019164
	for <netdev@vger.kernel.org>; Wed, 16 Jan 2008 15:08:31 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The two following patches do trivial changes to facilitate the
implementation of the network namespace in some protocols.

The first one pass the dst_ops as parameter to the gc functions.
The second patch just adds a netns pointer field into the dst_ops
structure.

-- 
