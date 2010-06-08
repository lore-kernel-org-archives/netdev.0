From: Sebastian Krahmer <krahmer@suse.de>
Subject: AF_PACKET meets AF_UNIX
Date: Tue, 8 Jun 2010 14:43:43 +0200
Message-ID: <20100608124343.GA8867@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:47792 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753477Ab0FHMno (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jun 2010 08:43:44 -0400
Received: from relay2.suse.de (charybdis-ext.suse.de [195.135.221.2])
	by mx2.suse.de (Postfix) with ESMTP id B4DF08AC33
	for <netdev@vger.kernel.org>; Tue,  8 Jun 2010 14:43:43 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I made a small fix for 2.6.34 to have something like
"tcpdump -i unix". For debugging purposes (DBUS etc)
it would be really helpfull. The sockaddr_ll struct
contains the socket's ino and the senders PID in
ifindex, so all necessary infos can be found
out via /proc/net/unix in userland.

The patch goes here: http://www.suse.de/~krahmer/unix-monitor-2.6.34.tgz

If you dont like any constructions in it please let me know,
so I can fix it and it can be accepted upstream :)

cya,
Sebastian

-- 
~
~ perl self.pl
~ $_='print"\$_=\47$_\47;eval"';eval
~ krahmer@suse.de - SuSE Security Team
~ SUSE LINUX Products GmbH, GF: Markus Rex, HRB 16746 (AG Nuernberg)

