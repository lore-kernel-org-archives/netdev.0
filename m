From: chriss <mail_to_chriss@gmx.net>
Subject: Re: 2.6.37 regression: adding main interface to a bridge breaks vlan interface RX
Date: Sat, 26 Feb 2011 11:51:27 +0000 (UTC)
Message-ID: <loom.20110226T120245-774@post.gmane.org>
References: <4D32FC1C.3010905@simon.arlott.org.uk> <201101231845.20505.maciej.rutecki@gmail.com> <AANLkTimTz=kMmJ=YhyJv28WUrsbN=ygBt9e7dMJ3KGqB@mail.gmail.com> <201101241625.45367.maciej.rutecki@gmail.com> <loom.20110205T163216-459@post.gmane.org> <AANLkTi=-+1dnh5ab6nMwjwMx20jpirYyaASZ=dk4OExp@mail.gmail.com> <loom.20110206T203347-475@post.gmane.org> <4D4FE100.5090808@gmail.com> <loom.20110214T141934-88@post.gmane.org> <AANLkTimFC5drwt44C7Hpn4YJU-Njksr8Zkiv_RXK_oSL@mail.gmail.com> <loom.20110226T011347-702@post.gmane.org> <AANLkTikSvs7jF9BZzbsYkLAawpCH2h1Z0r09ft219uaa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:39309 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751777Ab1BZLvk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Feb 2011 06:51:40 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1PtIgU-00052Z-KQ
	for netdev@vger.kernel.org; Sat, 26 Feb 2011 12:51:38 +0100
Received: from HSI-KBW-109-193-065-201.hsi7.kabel-badenwuerttemberg.de ([109.193.65.201])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 26 Feb 2011 12:51:38 +0100
Received: from mail_to_chriss by HSI-KBW-109-193-065-201.hsi7.kabel-badenwuerttemberg.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 26 Feb 2011 12:51:38 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesse Gross <jesse <at> nicira.com> writes:

> 
> Can you confirm this by running tcpdump -eni br0?  I would expect that
> you see the correct packets but without vlan tags.
> 

Thats correct. i see the packets in br0 without tags and tagged in eth1. thats
why i added the brouting rule in ebtables to drop it at eth1 and the it apears
in eth1.3 (untagged)...

