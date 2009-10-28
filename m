From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: WAN device configuration, again...
Date: Wed, 28 Oct 2009 14:28:51 +0100
Message-ID: <m3d447hcks.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:49718 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752054AbZJ1N2t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Oct 2009 09:28:49 -0400
Received: from intrepid.localdomain (intrepid.localdomain [10.0.0.2])
	by khc.piap.pl (Postfix) with ESMTP id EBE9292E2
	for <netdev@vger.kernel.org>; Wed, 28 Oct 2009 14:28:51 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm currently at final stages of "producing" two WAN drivers and there
is one thing to solve: they have really complex options. It's no longer
a V.35 with ca. 4 clock modes, a clock rate and few encodings etc. They
need many options unique to each driver/board. I think I need a more
capable interface to configure the devices than the current ioctl-based
one.

I think of something:
- using netlink or similar interface
- with potentially unlimited "payload" size (data may be transfered in
  smaller packets)
- the "command" and "response" should be variable-length ASCII-based,
  instead of fixed structures. This way I don't have to duplicate all
  option handling in userspace, only the specific driver has to know
  about them.

Comments? Perhaps there is already an example?
Should I use something else?

I also thought about using /sys read/write calls, but I'm not sure it's
a good idea.
-- 
Krzysztof Halasa
