From: Heiko Gerstung <heiko.gerstung@meinberg.de>
Subject: DMFE Driver in current kernel
Date: Wed, 16 Jun 2010 12:52:21 +0200
Message-ID: <4C18ACE5.8040008@meinberg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alster074.server4you.de ([62.75.216.94]:33015 "EHLO
	server2.meinberg.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753994Ab0FPLC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 07:02:58 -0400
Received: from localhost (localhost [127.0.0.1])
	by server2.meinberg.de (Postfix) with ESMTP id ACEF41EC4667
	for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 12:52:33 +0200 (CEST)
Received: from server2.meinberg.de ([127.0.0.1])
	by localhost (server2.meinberg.de [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id YSENgMB1MV6D for <netdev@vger.kernel.org>;
	Wed, 16 Jun 2010 12:52:22 +0200 (CEST)
Received: from gateway.py.meinberg.de (unknown [217.5.178.130])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	by server2.meinberg.de (Postfix) with ESMTP id 0AFC91EC462F
	for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 12:52:22 +0200 (CEST)
Received: from [172.16.3.102] (pc-heiko.py.meinberg.de [172.16.3.102])
	by gateway.py.meinberg.de (Postfix) with ESMTP id B097A13BB62
	for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 12:52:21 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear netdev members,

I apologize for contacting this list, I was pointed here by Tobias
Ringstroem who is listed as the current maintainer for the dmfe network
driver but he told me that this is not true anymore. I believe that
probably no one is looking at this driver anymore, and he suggested tha=
t
I should contact you guys because he cannot help me.

Here is my long worded story: We are a manufacturer of special network
appliances used for time synchronization and in our LANTIME time server
appliances we are currently using GNU Linux on an embedded i386 CPU
board with a Davicom network chip.

I am desperately missing an important feature in the dmfe driver (which
lists you as the current maintainer): I would want to be able to change
network speed and duplex settings without having to unload/reload the
kernel module, preferably by using ethtool.

Would anyone here interested in adding support for this into the driver=
?

If yes, we would want to pay for this (and of course we would love
to see that these changes are included in the next kernel version, if
possible). If nobody on this list is interested in this job, I would
appreciate recommendations regarding where to look for someone. If I do
not manage to find anyone for this task, I will try it on my own.
Pointers to suitable documentation or hints would be appreciated!

I know that this is a pretty old chip, but it seems that it is still
used in a number of embedded systems and since we want to be able to
upgrade our existing units in the field with our new firmware, I really
would like to get this functionality into the driver.

Another point I am looking for is how to get the asix driver to play
nice when used in combination with active-backup bonding. As it seems,
the current driver does not work unless I put the bonding interface int=
o
promiscuous mode (which I find out by accident when I used tcpdump for
debugging). If anyone has an idea how to improve this, I would be very
grateful, too.

Thanks for your time,
  Heiko


--=20

Heiko Gerstung

*MEINBERG Funkuhren* GmbH & Co. KG
Lange Wand 9
D-31812 Bad Pyrmont, Germany
Phone: +49 (0)5281 9309-25
=46ax: +49 (0)5281 9309-30
Amtsgericht Hannover 17HRA 100322
Gesch=C3=A4ftsf=C3=BChrer/Managing Directors: G=C3=BCnter Meinberg, Wer=
ner Meinberg,
Andre Hartmann, Heiko Gerstung
Email: heiko.gerstung@meinberg.de <mailto:heiko.gerstung@meinberg.de>
Web: www.meinberg.de <http://www.meinberg.de>

-----------------------------------------------------------------------=
-
*MEINBERG - Accurate Time Worldwide*


