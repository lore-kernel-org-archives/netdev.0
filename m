From: Andreas Hofmeister <andi@collax.com>
Subject: Subnet router anycast for FE80/10 ?
Date: Mon, 31 Oct 2011 21:22:41 +0100
Message-ID: <4EAF0391.80907@collax.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.collax.com ([213.218.25.154]:54418 "EHLO mail.collax.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751964Ab1JaUWo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Oct 2011 16:22:44 -0400
Received: from localhost (mail.collax.com [127.0.0.1])
	by localhost (Postfix) with ESMTP id 5F84B15F801C
	for <netdev@vger.kernel.org>; Mon, 31 Oct 2011 21:22:42 +0100 (CET)
Received: from mail.collax.com ([127.0.0.1])
	by localhost (mail.collax.com [127.0.0.1]) (amavisd-new, port 10033)
	with ESMTP id TMjAxOjGZXgk for <netdev@vger.kernel.org>;
	Mon, 31 Oct 2011 21:22:41 +0100 (CET)
Received: from andinc.coreworks.de (unknown [172.16.1.3])
	by mail.collax.com (Postfix) with ESMTPSA id 8FD2D15F801A
	for <netdev@vger.kernel.org>; Mon, 31 Oct 2011 21:22:41 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I noticed that once forwarding has been enabled on an interface, there 
is a "subnet router anycast address" for the link-local address prefix 
FE80/10.

This address seems not to be explicitly mentioned in any RFC, but RFC 
4291 says "All routers are required to support the Subnet-Router anycast 
addresses for the subnets to which they have interfaces."

In the sense that a Linux router actually has an address FE80/10 on each 
ipv6 enabled interface, it seems to be correct to also have FE80:: as an 
anycast address on all interfaces which have ipv6 and forwarding enabled.

But then, FE80/10 is not actually supposed to be routed at all and so a 
router cannot not really be a router for that particular subnet ?

Or is "FE80::" just supposed to be the anycast equivalent for the "all 
routers" multicast address ff02::2 ?

Maybe someone on this list could enlighten me.

Ciao
  Andi
