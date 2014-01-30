From: "Simon Schneider" <simon-schneider@gmx.net>
Subject: IPv4 / IPv6 over IPv4 IPsec tunnel: setting the DF bit
Date: Thu, 30 Jan 2014 13:25:10 +0100 (CET)
Message-ID: <trinity-bc5263ea-896d-4350-aa80-fd2895b54b3b-1391084710336@3capp-gmx-bs28>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:56975 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751799AbaA3MZM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jan 2014 07:25:12 -0500
Received: from 3capp-gmx-bs28.server.lan ([172.19.170.80]) by
 mrigmx.server.lan (mrigmx002) with ESMTP (Nemesis) id
 0LbO5M-1VOHe82MxO-00l0NP for <netdev@vger.kernel.org>; Thu, 30 Jan 2014
 13:25:10 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
for the scenarios
- IPv4 over IPv4 IPsec tunnel
- IPv6 over IPv4 IPsec tunnel

I wonder how the DF bit of the outer (encrypted) packet is set.

There are generally three options:
- DF bit always 0
- DF bit always 1
- DF bit copied from inner packet

(the last case is obviously not applicable for the IPv6 case, as the IPv6 header does not have a DF bit).

How is this done in Linux?

When investigating, I stumbled over defines named TNL_F_DF_INHERIT / TNL_F_DF_DEFAULT.

Are these still supported?

Is it possible to configure the behavior at runtime or just at compile time?

I would appreciate very much if someone could give an overview on this!

best regards, Simon
