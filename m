From: David Miller <davem@davemloft.net>
Subject: Re: Disabling msix interrupts
Date: Mon, 06 Feb 2017 14:14:49 -0500 (EST)
Message-ID: <20170206.141449.371774071782410941.davem@davemloft.net>
References: <063D6719AE5E284EB5DD2968C1650D6DB027C936@AcuExch.aculab.com>
        <CAKgT0UeXXkUpsrF9gpf_gba56V+B8a1G84k0WWt5q85Rx2PVsA@mail.gmail.com>
        <063D6719AE5E284EB5DD2968C1650D6DB027CB6A@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, netdev@vger.kernel.org,
        linux-pci@vger.kernel.org
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45884 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751372AbdBFTOz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 14:14:55 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB027CB6A@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM>
Date: Mon, 6 Feb 2017 17:23:54 +0000

> Although the 'store buffer' on the sparc cpus I used to use would
> let reads overtake writes. So you did have to read back the address
> of the last write - not sure about modern sparc cpus.

Never would any sparc cpu do so when any of the operations involved
were to "side effect" locations, as PCI config space is.
