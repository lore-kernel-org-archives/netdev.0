From: "George P Nychis" <gnychis@cmu.edu>
Subject: 2.4 kern: want to print TCP cwnd with every packet
Date: Sat, 6 May 2006 10:19:16 -0400 (EDT)
Message-ID: <28365.128.237.227.255.1146925156.squirrel@128.237.227.255>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.andrew.cmu.edu ([128.2.10.83]:16352 "EHLO
	smtp.andrew.cmu.edu") by vger.kernel.org with ESMTP
	id S1750822AbWEFOTQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 May 2006 10:19:16 -0400
Received: from webmail.andrew.cmu.edu (WEBMAIL8.andrew.cmu.edu [128.2.10.55])
	(user=gnychis mech=GSSAPI (56 bits))
	by smtp.andrew.cmu.edu (8.13.5/8.13.6) with ESMTP id k46EJGpZ011630
	for <netdev@vger.kernel.org>; Sat, 6 May 2006 10:19:16 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I'd like to print the TCP cwnd for the sender, with every packet before it is sent out.  This way i could plot the sender window over time to show TCP's behavior in certain conditions.

I see in tcp_input.c several places where i could print the current window, but i'd have to add code in multiple places.  I was wondering if there is any 1 place, right before a packet is sent out, that i could printk() tp->snd_cwnd

Thanks!
George

