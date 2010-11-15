From: Bastien Nocera <hadess@hadess.net>
Subject: ipheth "UI" problem
Date: Mon, 15 Nov 2010 15:13:16 +0000
Message-ID: <1289833997.6198.4.camel@novo.hadess.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Diego Giagio <diego@giagio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow3-v.mail.gandi.net ([217.70.178.89]:41123 "EHLO
	slow3-v.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753773Ab0KOPNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 10:13:43 -0500
Received: from relay2-d.mail.gandi.net (relay2-d.mail.gandi.net [217.70.183.194])
	by slow3-v.mail.gandi.net (Postfix) with ESMTP id B4C6F3821F
	for <netdev@vger.kernel.org>; Mon, 15 Nov 2010 16:13:39 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey Diego,

ipheth recently got added to the kernel, and seeped into Fedora. I love
the functionality of it (even though I'm more likely to be using the
Bluetooth tethering, to be honest).

I already filed a bug against NetworkManager connecting to the interface
automatically:
https://bugzilla.gnome.org/show_bug.cgi?id=633465

My problem is while I have disabled NetworkManager's automatic
connection, the kernel module still connects to the device, and I have a
constant "Internet Tethering" appearing on my iPhone.

Wouldn't it be possible to only check for the service being offered by
the device when plugging it in, and actually do the connection to the
service when we want to use it (when the interface is upped)?

Cheers 

PS: Re-sent with the correct ML address, sorry Diego

