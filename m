From: Roy Marples <roy@marples.name>
Subject: recv(2), MSG_TRUNK and kernels older than 2.6.22
Date: Tue, 20 Jul 2010 09:26:43 +0100
Message-ID: <4C455DC3.1050304@marples.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from uberserver.marples.name ([77.75.106.61]:65440 "EHLO
	uberserver.marples.name" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754231Ab0GTIfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 04:35:41 -0400
Received: from [IPv6:::1] (unknown [IPv6:2a01:348:31:2:6dfb:8172:a14f:ebf6])
	(using TLSv1 with cipher DHE-RSA-CAMELLIA256-SHA (256/256 bits))
	(No client certificate requested)
	by uberserver.marples.name (Postfix) with ESMTPSA id 9C32C27B0E
	for <netdev@vger.kernel.org>; Tue, 20 Jul 2010 09:26:44 +0100 (BST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I would like to support all possible kernels I can and previously used a 
fixed buffer of size 256 to read from netlink sockets. This is now 
proving too small for some 64-bit kernels so I would like to use recv(2) 
with MSG_TRUNK to wor out the size. However, the man page says that this 
only works for 2.6.22 kernels or newer.

My question is, what is the behaviour of recv on older kernels where 
MSG_TRUNC is not supported? I would rather not use some arbitary size if 
at all possible.

Reply directly please as I'm not subscribed here.

Thanks

Roy
