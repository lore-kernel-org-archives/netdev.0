From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/2] tcp: tcp_info extensions
Date: Tue, 28 Apr 2015 10:32:16 -0700
Message-ID: <1430242338-23156-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Eric Salo <salo@google.com>, Yuchung Cheng <ycheng@google.com>,
	Martin Lau <kafai@fb.com>, Chris Rapier <rapier@psc.edu>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f201.google.com ([209.85.192.201]:33272 "EHLO
	mail-pd0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030357AbbD1RcX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 13:32:23 -0400
Received: by pdjg10 with SMTP id g10so157952pdj.0
        for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 10:32:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As discussed during Chris Rapier presentation in Ottawa / netdev0.1,
we add to tcp_info the first two fields are highly wanted.

Each field is added into a single patch for easy code review.

(Corresponding iproute2/ss patches will be sent)

Next fields will follow once consensus is reached.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Matt Mathis <mattmathis@google.com>
Cc: Eric Salo <salo@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
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
