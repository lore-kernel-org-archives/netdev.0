From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC 0/2] Add IPsec virtual tunnel interfaces to IPv6
Date: Mon, 19 Aug 2013 08:26:23 +0200
Message-ID: <20130819062623.GN26773@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:34869 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750865Ab3HSG0Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Aug 2013 02:26:25 -0400
Received: from localhost (alg1 [127.0.0.1])
	by a.mx.secunet.com (Postfix) with ESMTP id 4AEBB1A007E
	for <netdev@vger.kernel.org>; Mon, 19 Aug 2013 08:26:24 +0200 (CEST)
Received: from a.mx.secunet.com ([127.0.0.1])
	by localhost (a.mx.secunet.com [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id c8UQ-5-UIvUr for <netdev@vger.kernel.org>;
	Mon, 19 Aug 2013 08:26:23 +0200 (CEST)
Received: from mail-srv1.secumail.de (unknown [10.53.40.200])
	by a.mx.secunet.com (Postfix) with ESMTP id 3964C1A007A
	for <netdev@vger.kernel.org>; Mon, 19 Aug 2013 08:26:23 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds support for IPsec virtual tunnel interfaces to IPv6.

IPsec virtual tunnel interfaces provide a routable interface for IPsec
tunnel endpoints. This does not add any tunnel headers, it uses the
generic xfrm tunneling. It just provides an interface for xfrm IPv6
tunnels, like the IPv4 side does.

It has not much testing yet, I can setup the interface and ping through it.
Review and further testing is very wellcome.

I'll send the necessary iproute2 patches in a separate thread.
