From: Oleg Verych <olecom@flower.upol.cz>
Subject: Stalled connection (need help to debug)
Date: Tue, 3 Jul 2007 20:48:46 +0000 (UTC)
Message-ID: <slrnf8le9t.2kl.olecom@flower.upol.cz>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:54949 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750706AbXGCUtH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jul 2007 16:49:07 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1I5pIz-0006mv-Cg
	for netdev@vger.kernel.org; Tue, 03 Jul 2007 22:49:01 +0200
Received: from flower.upol.cz ([158.194.64.22])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 03 Jul 2007 22:49:01 +0200
Received: from olecom by flower.upol.cz with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 03 Jul 2007 22:49:01 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hallo.

I have a very strange problem.

Server (with Debian Etch) was running for 80 days perfectly. Then, (after
some lighting, i believe) i noticed, that connection, that isn't active
(i.e. is not transferring something) frizzes (on linux) and then
dies (connections reset).

Logs are empty. Ping is working, reconnection is OK. But if it's not
active ==> same stall.

Server is pretty far way and after i tried everything (reconfigure IF,
different client OSes), i've rebooted it. Still the same problem. I
didn't do power cycle though.

I use this server as my Internet ant (it's flower.upol.cz, BTW).
I do ssh && screen -x to work on it. The only way i still can do this,
it's my clock.sh script (updates tty with current time after 1 sec):

$ ssh && clock.sh && exec screen -x

Any advise on how to debug this will be very appreciated. Thanks.

--
-o--=O`C
 #oo'L O
<___=E M

