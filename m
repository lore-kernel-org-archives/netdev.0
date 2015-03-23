From: Sasha Levin <sasha.levin@oracle.com>
Subject: rhashtable: warnings caused by "rhashtable: Fix use-after-free in
 rhashtable_walk_stop"
Date: Mon, 23 Mar 2015 14:27:58 -0400
Message-ID: <55105B2E.1070409@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Commit 963ecbd41a ("rhashtable: Fix use-after-free in rhashtable_walk_stop") is causing
RCU warnings since the code now locks a mutex (which might sleep) within an RCU critical
section within rhashtable_walk_stop().


Thanks,
Sasha
