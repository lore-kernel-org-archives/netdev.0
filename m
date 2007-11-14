From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: [PATCH 2/2] [e1000 VLAN] Disable vlan hw accel when promiscuous mode
Date: Wed, 14 Nov 2007 12:48:04 +0100
Message-ID: <m3sl39yrnv.fsf@ursa.amorsen.dk>
References: <47365200.0f10240a.0686.2173@mx.google.com> <47388988.1000506@intel.com> <47388B9F.7050308@trash.net> <20071112.143342.10809862.davem@davemloft.net> <4738D70C.4060404@nortel.com> <4738D9AB.8080408@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: e1000-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:33108 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754709AbXKNLsY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 06:48:24 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1IsGjE-0002bQ-NS
	for netdev@vger.kernel.org; Wed, 14 Nov 2007 11:48:20 +0000
Received: from hd5b9080a.c45-01-12.sta.perspektivbredband.net ([213.185.8.10])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 14 Nov 2007 11:48:20 +0000
Received: from benny+usenet by hd5b9080a.c45-01-12.sta.perspektivbredband.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 14 Nov 2007 11:48:20 +0000
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>> "AK" == Kok, Auke <auke-jan.h.kok@intel.com> writes:

AK> actually the impact can be quite negative, imagine doing a tcpdump
AK> on a 10gig interface with vlan's enabled - all of a sudden you
AK> might accidentally flood the system with a 100-fold increase in
AK> traffic and force the stack to dump all those packets for you.

Why is the switch sending you all that traffic for VLAN's you don't
care about? I have a hard time imagining such a scenario. Sure, you
could have forgotten to limit the VLAN range sent to a particular
host, or even have decided that it's administratively easier to just
allow everything, but the switch still won't send unicast traffic out
that port unless the destination MAC matches. If broadcast or
non-solicited multicast takes up most of your bandwidth, you have
other problems.


/Benny


