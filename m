From: elelueck@linux.vnet.ibm.com
Subject: [RFC PATCH V2] tcp: introduce raw access to experimental options
Date: Mon,  7 Jan 2013 17:13:29 +0100
Message-ID: <1357575210-52926-1-git-send-email-elelueck@linux.vnet.ibm.com>
Cc: Einar Lueck <elelueck@linux.vnet.ibm.com>, davem@davemloft.net,
	ubacher@de.ibm.com, raspl@de.ibm.com, frankbla@de.ibm.com,
	samudrala@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp12.uk.ibm.com ([195.75.94.108]:39508 "EHLO
	e06smtp12.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753662Ab3AGQNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 11:13:54 -0500
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <elelueck@linux.vnet.ibm.com>;
	Mon, 7 Jan 2013 16:12:59 -0000
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r07GDfkw63242416
	for <netdev@vger.kernel.org>; Mon, 7 Jan 2013 16:13:41 GMT
Received: from d06av05.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r07GDm8q026965
	for <netdev@vger.kernel.org>; Mon, 7 Jan 2013 09:13:49 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Einar Lueck <elelueck@linux.vnet.ibm.com>

V2 addresses the privilige concern. CAP_NET_RAW is now required for all of the
new socket options.

Einar Lueck (1):
  tcp: introduce raw access to experimental options

 include/linux/tcp.h      |  23 +++++++++
 include/net/tcp.h        |   3 ++
 include/uapi/linux/tcp.h |   3 ++
 net/ipv4/tcp.c           | 122 +++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_input.c     | 119 ++++++++++++++++++++++++++++++---------------
 net/ipv4/tcp_ipv4.c      |  14 ++++++
 net/ipv4/tcp_minisocks.c |  17 +++++++
 net/ipv4/tcp_output.c    |  47 +++++++++++-------
 8 files changed, 293 insertions(+), 55 deletions(-)

-- 
1.7.12.4
