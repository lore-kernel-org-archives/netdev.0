From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: [PATCH] net/ipv4/arp.c: Fix arp reply when sender ip 0
Date: Fri, 16 Nov 2007 15:13:01 +0100
Message-ID: <m3r6iqffde.fsf@ursa.amorsen.dk>
References: <cac0ab7d0711151340l1cc91a2dw5ebf36e166d16d7a@mail.gmail.com> <20071115.152813.89410917.davem@davemloft.net> <cac0ab7d0711160030w149c7a7s2db55ac56d0a05cc@mail.gmail.com> <20071116.010548.94286711.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:34778 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752595AbXKPONi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Nov 2007 09:13:38 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1It1wZ-0000Hc-W7
	for netdev@vger.kernel.org; Fri, 16 Nov 2007 14:13:16 +0000
Received: from hd5b9080a.c45-01-12.sta.perspektivbredband.net ([213.185.8.10])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 16 Nov 2007 14:13:15 +0000
Received: from benny+usenet by hd5b9080a.c45-01-12.sta.perspektivbredband.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 16 Nov 2007 14:13:15 +0000
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>> "DM" == David Miller <davem@davemloft.net> writes:

>> Reply:
>> Opcode: reply (0x0002)
>> Sender HW: 00:AA.00:AA:00:AA
>> Sender IP:   192.168.0.1
>> Target HW:  00:AA:00:AA:00:AA
>> Target IP:    192.168.0.1

DM> And this is exactly a sensible response in my opinion.

Why send the reply at all? Sending a unicast packet with yourself as
destination MAC seems a bit useless. Do switches propagate it?


/Benny


