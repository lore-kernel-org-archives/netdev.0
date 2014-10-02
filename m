From: Andy Lutomirski <luto@amacapital.net>
Subject: FOU RX interface?
Date: Wed, 1 Oct 2014 22:14:02 -0700
Message-ID: <CALCETrXPKRm16avRoDFtE6-o+x-=n4Xq1BTZsbzkUYLTLOeXVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Network Development <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:57560 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998AbaJBFOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 01:14:24 -0400
Received: by mail-lb0-f174.google.com with SMTP id p9so1591148lbv.33
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 22:14:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi-

Sorry for the lack of proper threading here -- I lost the original message.

If I'm understanding the FOU use case correctly, if I set up a FOU
tunnel tun0 that is encapsulated in UDP on eth0, then tun0 packets
will be transmitted on tun0, but incoming packets will show up on eth0
when they're reinjected after stripping the FOU header.

Is this right?  I think that, without a way to reinject the received
packets on the tunnel interface, using FOU will be annoying.  For
example, writing firewall rules might be tricky.  And programs that
use packet sockets or SO_BINDTODEVICE could have a hard time being
configured such that they notice the received packets.

Also, is it even possible to assign a FOU tunnel to a different
network namespace than the device that's being tunneled over?  How
will the received packets end up in the right netns?

--Andy
