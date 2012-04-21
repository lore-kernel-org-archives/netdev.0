From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: My e1000e GBE card is eating all port 623 pks
Date: Sat, 21 Apr 2012 15:31:09 +0200
Message-ID: <OF8F83D7F0.387F6CCE-ONC12579E7.0049B885-C12579E7.004A4356@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:46259 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751567Ab2DUNbM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Apr 2012 09:31:12 -0400
Received: from mail1.transmode.se (mail1.transmode.se [192.168.201.18])
	by gw1.transmode.se (Postfix) with ESMTP id 5EB6F258136
	for <netdev@vger.kernel.org>; Sat, 21 Apr 2012 15:31:10 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Looks like port 623 is some mgmt protocol and our e1000e boards are eating these
pkgs and this trips NIS, finger and yptest hangs for a long time before timing out and
moving on.

Is there a way to tell the network stack not to eat port 623 pkgs or
have NIS not to use port 623?

 Jocke
