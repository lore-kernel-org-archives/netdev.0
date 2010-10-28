From: Heiko Gerstung <heiko.gerstung@meinberg.de>
Subject: Does ip does support labels for IPv6 addresses?
Date: Thu, 28 Oct 2010 12:41:52 +0200
Message-ID: <4CC95370.1010201@meinberg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alster074.server4you.de ([62.75.216.94]:38865 "EHLO
	server2.meinberg.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752597Ab0J1KuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 06:50:22 -0400
Received: from localhost (localhost [127.0.0.1])
	by server2.meinberg.de (Postfix) with ESMTP id 706E01CE0026
	for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 12:42:02 +0200 (CEST)
Received: from server2.meinberg.de ([127.0.0.1])
	by localhost (server2.meinberg.de [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id QQRmLSHMrWm9 for <netdev@vger.kernel.org>;
	Thu, 28 Oct 2010 12:41:56 +0200 (CEST)
Received: from gateway.py.meinberg.de (unknown [217.5.178.131])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	by server2.meinberg.de (Postfix) with ESMTP id BABEA1CE0024
	for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 12:41:55 +0200 (CEST)
Received: from localhost (localhost [127.0.0.1])
	by gateway.py.meinberg.de (Postfix) with ESMTP id 36AB6252728
	for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 12:41:55 +0200 (CEST)
Received: from gateway.py.meinberg.de ([127.0.0.1])
 by localhost (gateway [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
 id 28508-09 for <netdev@vger.kernel.org>;
 Thu, 28 Oct 2010 12:41:52 +0200 (CEST)
Received: from [172.16.100.7] (pc-heiko.py.meinberg.de [172.16.100.7])
	by gateway.py.meinberg.de (Postfix) with ESMTP id 902E523D7E5
	for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 12:41:52 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi !

Not sure if this is where I should ask, please feel free to send me to
someone else.

I just tried to use "ip" (from the iproute2 project) to assign multiple
IPv6 addresses to a physical network interface. In order to be able to
distinguish between them, I wanted to use the "label" feature as
described on the ip man page, but it seems that this is not supported
for IPv6 addresses.

Does anybody know if this is a (documentation-)bug, a feature or a
misconfiguration of ~/brain ?

Example:

# ip addr add dev eth0 2001::23/64 label eth0:0

at least adds the address correctly. But when I want to check with
# ip addr show
the label is not listed anywhere and using
# ip addr show label "eth0:0" does not work either (does not come up
with any output at all).

The description of the "label" option on the man page does not mention
that this is not supported on IPv6.

Best Regards,
 Heiko


--=20

Heiko Gerstung

*MEINBERG Funkuhren* GmbH & Co. KG
Lange Wand 9
D-31812 Bad Pyrmont, Germany
Phone: +49 (0)5281 9309-25
=46ax: +49 (0)5281 9309-30
Amtsgericht Hannover 17HRA 100322
Gesch=E4ftsf=FChrer/Managing Directors: G=FCnter Meinberg, Werner Meinb=
erg,
Andre Hartmann, Heiko Gerstung
Email: heiko.gerstung@meinberg.de <mailto:heiko.gerstung@meinberg.de>
Web: www.meinberg.de <http://www.meinberg.de>

-----------------------------------------------------------------------=
-
*MEINBERG - Accurate Time Worldwide*

