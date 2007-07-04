From: "Robert Iakobashvili" <coroberti@gmail.com>
Subject: Beyond 64K TCP connections limit per IP-address
Date: Wed, 4 Jul 2007 09:50:31 +0200
Message-ID: <7e63f56c0707040050k7d1a9daeq276d7d924ef802e8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.234]:50400 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753579AbXGDHub (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2007 03:50:31 -0400
Received: by wx-out-0506.google.com with SMTP id h31so2014668wxd
        for <netdev@vger.kernel.org>; Wed, 04 Jul 2007 00:50:31 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If I am correct, a TCP server can make up to
64K accepts for a port at a single IP-address.

If one would like to have e.g. 1M TCP connections
to a single IP-address of a powerful server (without load balancer),
how to make such setup?

There is a workaround to arrange several secondary IP-addresses
each serving ~64K connections.
Any other options?

Server places to the outgoing packet source port the port
of the server listening socket. Actually, the ephemeral ports at the
server side are used as the hashing keys.
Could it be played, tricked somehow?

Y comments would be appreciated.

-- 
Sincerely,
Robert Iakobashvili,
coroberti %x40 gmail %x2e com
...........................................................
http://curl-loader.sourceforge.net
A web testing and traffic generation tool.
