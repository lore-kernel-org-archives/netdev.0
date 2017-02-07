From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: Disabling msix interrupts
Date: Tue, 7 Feb 2017 09:55:47 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB027DA37@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6DB027C936@AcuExch.aculab.com>
        <CAKgT0UeXXkUpsrF9gpf_gba56V+B8a1G84k0WWt5q85Rx2PVsA@mail.gmail.com>
        <063D6719AE5E284EB5DD2968C1650D6DB027CB6A@AcuExch.aculab.com>
 <20170206.141449.371774071782410941.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: 'David Miller' <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.189]:64857 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752323AbdBGJz5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 04:55:57 -0500
In-Reply-To: <20170206.141449.371774071782410941.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller
> Sent: 06 February 2017 19:15
> From: David Laight <David.Laight@ACULAB.COM>
> Date: Mon, 6 Feb 2017 17:23:54 +0000
> 
> > Although the 'store buffer' on the sparc cpus I used to use would
> > let reads overtake writes. So you did have to read back the address
> > of the last write - not sure about modern sparc cpus.
> 
> Never would any sparc cpu do so when any of the operations involved
> were to "side effect" locations, as PCI config space is.

I guess they used non-zero ASI, and that forced the flush??
Normal uncached memory reads would overtake writes.
(These were SuperSparc (Viking)).

	David
