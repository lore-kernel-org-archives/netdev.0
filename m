From: Hadmut Danisch <hadmut@danisch.de>
Subject: Privacy extension for unique local networks?
Date: Mon, 12 Dec 2011 14:23:14 +0100
Message-ID: <4EE60042.5010704@msgid.danisch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.rackland.de ([212.86.200.188]:39155 "EHLO mail.rackland.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753159Ab1LLNbd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Dec 2011 08:31:33 -0500
Received: from [192.168.160.10] (178-26-43-170-dynip.superkabel.de [178.26.43.170])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	by mail.rackland.de (Postfix) with ESMTPSA id BA67B259A4
	for <netdev@vger.kernel.org>; Mon, 12 Dec 2011 14:23:12 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have a particular problem with my IPv6 home network:

I need to enable auto configuration since my Router has dynamic IPv4
addresses and uses 6to4 tunneling, thus the IPv6 prefix also changes and
is announced by the Router (2002:...). Works.

Since several programs (including e.g. Samba) refuse to use the link
local addresses (FE80:..), and I do not want to open my server ports
just for any 2002:... address, I let my router announce an additional
unique address (FD00:...). Works as well.

I enabled the privacy extension on the interfaces because I want to
avoid beeing tracked by Webservers in the Internet, since the
2002:-Adresses are derived from the MAC address. Works also.


The problem: The Linux kernel's privacy mechanism assigns dynamic
changing to the FD00: address range also, which does not make sense and
makes my machines to use changing local addresses. Makes it difficult to
assign local permissions based on IP addresses.


The privacy mechanism should be restricted to public addresses (or at
least there should be a separate switch to turn it on and off for unique
local addresses).



regards
Hadmut

(Please reply directly, I am not on your mailing list)
