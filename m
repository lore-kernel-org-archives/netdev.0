From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/2] batman-adv: Fix double call of dev_queue_xmit
Date: Mon, 30 Jan 2017 12:07:19 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0273A88@AcuExch.aculab.com>
References: <20170128105651.3061-1-sw@simonwunderlich.de>
 <20170128105651.3061-2-sw@simonwunderlich.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "b.a.t.m.a.n@lists.open-mesh.org" <b.a.t.m.a.n@lists.open-mesh.org>,
        "Sven Eckelmann" <sven@narfation.org>
To: 'Simon Wunderlich' <sw@simonwunderlich.de>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.193]:56094 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753116AbdA3Mqc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 07:46:32 -0500
In-Reply-To: <20170128105651.3061-2-sw@simonwunderlich.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich
> Sent: 28 January 2017 10:57
> From: Sven Eckelmann <sven@narfation.org>
> 
> The net_xmit_eval has side effects because it is not making sure that e
> isn't evaluated twice.
> 
>     #define net_xmit_eval(e)        ((e) == NET_XMIT_CN ? 0 : (e))

It is probably worth fixing the #define.

	David
