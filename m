From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 0/2] tcp: tcp_info extensions
Date: Tue, 28 Apr 2015 15:28:16 -0700
Message-ID: <1430260098-14127-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Eric Salo <salo@google.com>, Martin Lau <kafai@fb.com>,
	Chris Rapier <rapier@psc.edu>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f74.google.com ([209.85.192.74]:33555 "EHLO
	mail-qg0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030988AbbD1W23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 18:28:29 -0400
Received: by qgdz60 with SMTP id z60so332962qgd.0
        for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 15:28:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As discussed during Chris Rapier presentation in Ottawa / netdev0.1,
we add to tcp_info the first two fields are highly wanted.

Each field is added into a single patch for easy code review.

(Corresponding iproute2/ss patches will be sent)

Next fields will follow once consensus is reached.

v2: Addressed Yuchung feedback about FastOpen and bytes_received

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Matt Mathis <mattmathis@google.com>
Cc: Eric Salo <salo@google.com>
Cc: Martin Lau <kafai@fb.com>
Cc: Chris Rapier <rapier@psc.edu>

Eric Dumazet (2):
  tcp: add tcpi_bytes_acked to tcp_info
  tcp: add tcpi_bytes_received to tcp_info

 include/linux/tcp.h      |  8 ++++++++
 include/net/tcp.h        |  2 +-
 include/uapi/linux/tcp.h |  2 ++
 net/ipv4/tcp.c           |  7 ++++++-
 net/ipv4/tcp_input.c     | 30 ++++++++++++++++++++++++------
 5 files changed, 41 insertions(+), 8 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
