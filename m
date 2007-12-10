From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 0/5] ipv6:  make af_inet6 subsystems to return an error at init
Date: Mon, 10 Dec 2007 16:09:10 +0100
Message-ID: <20071210150910.440970057@ICON-9-164-138-215.megacenter.de.ibm.com>
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:46501 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751177AbXLJPRa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 10:17:30 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.8/8.13.8) with ESMTP id lBAFHSmv411864
	for <netdev@vger.kernel.org>; Mon, 10 Dec 2007 15:17:28 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBAFHTTB2838570
	for <netdev@vger.kernel.org>; Mon, 10 Dec 2007 16:17:29 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBAFHSg3021016
	for <netdev@vger.kernel.org>; Mon, 10 Dec 2007 16:17:29 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset continue the work to make the different af_inet6 
subsystems initialization functions to return an error code and
to handle the error to fails safely.

It takes into account:
	* flowlabel
	* exthdrs
	* frag
	* udp
	* udplite
	* tcp
	* raw
-- 
