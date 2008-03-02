From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 00/11][NETNS][IPV6] make a subset of the routing per namespace
Date: Sun, 02 Mar 2008 10:37:20 +0100
Message-ID: <20080302093720.649869114@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:16700 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759AbYCBJnX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2008 04:43:23 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id m229hKwQ101424
	for <netdev@vger.kernel.org>; Sun, 2 Mar 2008 09:43:20 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m229hJvp528438
	for <netdev@vger.kernel.org>; Sun, 2 Mar 2008 10:43:19 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m229hIgv030290
	for <netdev@vger.kernel.org>; Sun, 2 Mar 2008 09:43:19 GMT
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
