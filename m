From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] ECN and IP defragmentation
Date: Wed, 05 Jan 2011 01:13:51 +0100
Message-ID: <1294186431.3420.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51646 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750940Ab1AEANz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 19:13:55 -0500
Received: by wwa36 with SMTP id 36so15759053wwa.1
        for <netdev@vger.kernel.org>; Tue, 04 Jan 2011 16:13:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

It seems ip_fragment.c doesnt comply with RFC3168, section 5.3

5.3.  Fragmentation

   ECN-capable packets MAY have the DF (Don't Fragment) bit set.
   Reassembly of a fragmented packet MUST NOT lose indications of
   congestion.  In other words, if any fragment of an IP packet to be
   reassembled has the CE codepoint set, then one of two actions MUST be
   taken:

      * Set the CE codepoint on the reassembled packet.  However, this
        MUST NOT occur if any of the other fragments contributing to
        this reassembly carries the Not-ECT codepoint.

      * The packet is dropped, instead of being reassembled, for any
        other reason.




Should we fix this ?

(I tried to use ECN on UDP messages and noticed this problem)

Thanks


