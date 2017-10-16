From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 00/10] korina cleanups/optimizations
Date: Mon, 16 Oct 2017 12:59:14 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0097CDD@AcuExch.aculab.com>
References: <20171015162226.606-1-roman@advem.lv>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Roman Yeryomin' <roman@advem.lv>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.195]:63113 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751448AbdJPM7N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 08:59:13 -0400
In-Reply-To: <20171015162226.606-1-roman@advem.lv>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roman Yeryomin
> Sent: 15 October 2017 17:22
> TX optimizations have led to ~15% performance increase (35->40Mbps)
> in local tx usecase (tested with iperf v3.2).

Indicate which patches give the improvement.
IIRC some just changed the source without changing what the code really did.
(Not a problem in itself.)

...
>   net: korina: optimize tx/rx interrupt handlers

You'd probably get a noticeable improvement from caching the
value of the interrupt mask - instead of reading it from the hardware.
...

	David
