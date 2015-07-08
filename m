From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 0/2] net: pktgen: fix race between pktgen_thread_worker()
	and kthread_stop()
Date: Wed, 8 Jul 2015 21:41:54 +0200
Message-ID: <20150708194154.GA26534@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Stancek <jstancek@redhat.com>,
	Marcelo Leitner <mleitner@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37656 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758659AbbGHTn2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jul 2015 15:43:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I am not familiar with this code and I have no idea how to test
these changes, so 2/2 comes as a separate change. 1/2 looks like
the obvious bugfix, and probably candidate for -stable.

Oleg.

 net/core/pktgen.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)
