From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: accept RST if SEQ matches right edge of
 right-most SACK block
Date: Mon, 6 Jun 2016 14:23:49 -0400
Message-ID: <CADVnQymeArQhGTUFuTXQb4v3aabzseumybjpJ8UtTugnX=2=cA@mail.gmail.com>
References: <CADVnQykAac+V=tN0k5YXYRrA5sqi0+9FyPO2SppOZQWReELeow@mail.gmail.com>
 <1465204909-2092-1-git-send-email-pau.espin@tessares.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>
To: Pau Espin Pedrol <pau.espin@tessares.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:33577 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752870AbcFFSYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 14:24:20 -0400
Received: by mail-oi0-f52.google.com with SMTP id k23so239683757oih.0
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 11:24:20 -0700 (PDT)
In-Reply-To: <1465204909-2092-1-git-send-email-pau.espin@tessares.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The functionality seems OK to me, though there are some
style/formatting issues, which checkpatch.pl picks up:

> ./scripts/checkpatch.pl net-next-tcp-accept-RST-if-SEQ-matches-right-edge-of-right-most-SACK-block.patch
WARNING: line over 80 characters
#73: FILE: net/ipv4/tcp_input.c:5199:
+               /* RFC 5961 3.2 (extended to match against SACK too if
available):

WARNING: line over 80 characters
#74: FILE: net/ipv4/tcp_input.c:5200:
+                * If seq num exactly matches RCV.NXT or the
right-most SACK block,

WARNING: line over 80 characters
#88: FILE: net/ipv4/tcp_input.c:5213:
+                       for (this_sack = 1; this_sack <
tp->rx_opt.num_sacks; ++this_sack) {

WARNING: line over 80 characters
#89: FILE: net/ipv4/tcp_input.c:5214:
+                               max_sack =
after(sp[this_sack].end_seq, max_sack) ?

WARNING: line over 80 characters
#90: FILE: net/ipv4/tcp_input.c:5215:
+
sp[this_sack].end_seq : max_sack;

total: 0 errors, 5 warnings, 0 checks, 40 lines checked

neal
