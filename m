From: Sebastian Ott <sebott@linux.vnet.ibm.com>
Subject: ipv6 csum failures on MLX4 VFs
Date: Fri, 12 Feb 2016 17:43:20 +0100 (CET)
Message-ID: <alpine.LFD.2.20.1602121732310.20641@schleppi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Carol L Soto <clsoto@linux.vnet.ibm.com>,
	Muhammad Mahajna <muhammadm@mellanox.com>,
	netdev@vger.kernel.org
To: Yishai Hadas <yishaih@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:35068 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961AbcBLQnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2016 11:43:25 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sebott@linux.vnet.ibm.com>;
	Fri, 12 Feb 2016 16:43:23 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 9EC5F17D8042
	for <netdev@vger.kernel.org>; Fri, 12 Feb 2016 16:43:38 +0000 (GMT)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1CGhMMU30933230
	for <netdev@vger.kernel.org>; Fri, 12 Feb 2016 16:43:22 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1CGhLQM024024
	for <netdev@vger.kernel.org>; Fri, 12 Feb 2016 11:43:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I receive tons of these csum failure warnings. The patch mentioned here:
	https://patchwork.ozlabs.org/patch/512005/

seems to work. Will something like that be integrated upstream?

Sebastian
