From: Andreas Klauer <Andreas.Klauer@metamorpher.de>
Subject: 2.6.34 + IPv6: Oops?
Date: Sat, 19 Jun 2010 19:53:52 +0200
Message-ID: <20100619175352.GA8482@EIS>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay02.ispgateway.de ([80.67.31.29]:55917 "EHLO
	smtprelay02.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753173Ab0FSSAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jun 2010 14:00:15 -0400
Received: from [93.211.40.224] (helo=localhost)
	by smtprelay02.ispgateway.de with esmtpsa (TLSv1:AES128-SHA:128)
	(Exim 4.68)
	(envelope-from <Andreas.Klauer@metamorpher.de>)
	id 1OQ2Eq-000339-AF
	for netdev@vger.kernel.org; Sat, 19 Jun 2010 19:53:52 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have a NULL pointer dereference Oops here which I can reproduce, 
and I believe it's related to network / IPv6 somehow since sending a
ping from outside to the IPv6 address is what ultimately triggers it.

The box is a dedicated server with a /64 subnet assigned to it.
What I'm trying to do is tunnel part of it through IPv4 / OpenVPN.
I'm completely new to IPv6 so I'm probably doing this horribly wrong.

Unfortunately I only have a screenshot of the Oops.
I uploaded it along with other information here:

http://www.metamorpher.de/kernel/

Before the Oops I'm running a shell script (see link above) 
which among other things sets up proxy_ndp on eth0 (r8169 driver).
The Oops is triggered by sending a ping from the outside world to 
the IP which was intended to be tunneled (2a01:4f8:120:8221:ffff::2).

If you need more information, I'll try my best to provide it. 
If it's a kernel bug, I'll also be happy to test any patches.

Regards
Andreas Klauer
