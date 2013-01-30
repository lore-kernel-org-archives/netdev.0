From: CAI Qian <caiqian@redhat.com>
Subject: request for stable inclusion
Date: Wed, 30 Jan 2013 01:16:15 -0500 (EST)
Message-ID: <603624767.11006664.1359526575633.JavaMail.root@redhat.com>
References: <1448044634.10999492.1359525527955.JavaMail.root@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4-phx2.redhat.com ([209.132.183.25]:37756 "EHLO
	mx4-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751482Ab3A3GQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 01:16:16 -0500
Received: from zmail14.collab.prod.int.phx2.redhat.com (zmail14.collab.prod.int.phx2.redhat.com [10.5.83.16])
	by mx4-phx2.redhat.com (8.13.8/8.13.8) with ESMTP id r0U6GFbr026067
	for <netdev@vger.kernel.org>; Wed, 30 Jan 2013 01:16:15 -0500
In-Reply-To: <1448044634.10999492.1359525527955.JavaMail.root@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

9c13cb8bb477a83b9a3c9e5a5478a4e21294a760
tg3: Avoid null pointer dereference in tg3_interrupt in netconsole mode

daf3ec688e057f6060fb9bb0819feac7a8bbf45c
tg3: Fix crc errors on jumbo frame receive

The above 2 commits looks like missing from the stable and the netdev
stable queues. It was observed that the above issues can be reproduced in
a kernel that as old as a 2.6.32-based fedora kernel, so I'd like to request
to include them for 3.0.y, 3.4.y and 3.7.y.

1e47ee8367babe6a5e8adf44a714c7086657b87e
netfilter: nf_conntrack: fix BUG_ON while removing nf_conntrack with netns

This one looks like a candidate for 3.7-stable but also missing from the
queues. Do you agree?

Regards,
CAI Qian
