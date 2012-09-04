From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Commit "ipconfig wait for carrier" makes boot hang for 2 mins if no carrier
Date: Tue, 4 Sep 2012 16:41:03 +0200
Message-ID: <OF61EF9E6E.9EF08C21-ONC1257A6F.004FE9B4-C1257A6F.0050A9B2@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: netdev@vger.kernel.org, Micha Nelissen <micha@neli.hopto.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:54586 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753192Ab2IDOuQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Sep 2012 10:50:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Above mentioned commit(3fb72f1e6e6165c5f495e8dc11c5bbd14c73385c) changes
a ~1 sec delay to ~120 sec boot delay if no carrier. This is a really
long time to wait if you just want to set an IP address but doesn't
care about NFS root, holds up the boot with 2 minutes.

 Jocke
