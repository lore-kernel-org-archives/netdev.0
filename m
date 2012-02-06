From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Strange pppoe problem - duplicate packages
Date: Mon, 6 Feb 2012 20:02:04 +0100
Message-ID: <OF235FF8C1.78D68B24-ONC125799C.006795F0-C125799C.00688F84@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:36632 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752555Ab2BFTK7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Feb 2012 14:10:59 -0500
Received: from mail1.transmode.se (mail1.transmode.se [192.168.201.18])
	by gw1.transmode.se (Postfix) with ESMTP id B0E0425839E
	for <netdev@vger.kernel.org>; Mon,  6 Feb 2012 20:02:05 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Trying to debug a problem at customer site(don't have any tools really) what seems to
be some sort of duplication of pppoe pkgs.

I got 2 pppoe links going out on the same eth0 I/F to 2 different MAC addresses but with the
same session ID.

pinging one neighbour results in 2 replies, one from each pppoe neighbour!
It looks like linux is ignoring the different MAC addresses somehow and just uses
the session ID and since it is the same session ID, I get 2 pkgs.

Does this sound familiar to anyone? Any idea where to start looking? I suspect the
TX patch somehow duplicating the pkgs.

 Jocke

PS.
    My kernel is somewhat old, 2.6.35, but I have checked current sources and it
    doesn't look like there has been any significat changes in this area.
