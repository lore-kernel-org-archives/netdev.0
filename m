From: nick black <dankamongmen@gmail.com>
Subject: is PACKET_TX_RING expected to work on loopback?
Date: Thu, 6 Oct 2011 14:37:32 -0400
Message-ID: <20111006183732.GA24014@qemfd.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-net@vger.kernel.org
To: Vitali Lovitch <vlovich@qualcomm.com>,
	Johann Baudy <johann.baudy@gnu-log.net>,
	David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:57305 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755185Ab1JFTEg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 15:04:36 -0400
Received: by gyg10 with SMTP id 10so2904424gyg.19
        for <netdev@vger.kernel.org>; Thu, 06 Oct 2011 12:04:35 -0700 (PDT)
Received: from recombinator.qemfd.net (localhost.localdomain [127.0.0.1])
	by vps.qemfd.net (Postfix) with ESMTP id 2CBC62B136
	for <netdev@vger.kernel.org>; Thu,  6 Oct 2011 15:04:33 -0400 (EDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey there. I'm developing an application which makes use of PACKET_TX_R=
ING
(http://dank.qemfd.net/dankwiki/index.php/Omphalos), one mmap'd RX and =
TX
socket per interface. When I transmit on wireless/ethernet devices, the
packets flow out fine, and I get responses.

When I transmit on loopback, I can see the packets using tcpdump -i lo,=
=20
send() returns 0, and the frame is set back to TP_STATUS_AVAILABLE.
Checksums are properly set and the packets appear well-formed in Wiresh=
ark.
I can't seem to read the packets, however; neither the intended DNS ser=
ver
(verified via dnsmasq -d and strace) nor my own socat udp-listen proces=
s
seem to get the packets.

Is PACKET_TX_RING expected to work on loopback?

Thanks!

--=20
                                         nick black <nblack@nvidia.com>
"A main cause of the Roman Empire's fall was that=E2=80=93lacking zero=E2=
=80=93they had
       no way to indicate successful termination of their C programs."
