From: Colin King <colin.king@canonical.com>
Subject: [PATCH][next] sctp: make array sctp_sched_ops static
Date: Wed, 11 Oct 2017 11:17:57 +0100
Message-ID: <20171011101757.18825-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        "David S . Miller" <davem@davemloft.net>,
        linux-sctp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The array sctp_sched_ops  is local to the source and
does not need to be in global scope, so make it static.

Cleans up sparse warning:
symbol 'sctp_sched_ops' was not declared. Should it be static?

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/sctp/stream_sched.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/stream_sched.c b/net/sctp/stream_sched.c
index 03513a9fa110..0b83ec51e43b 100644
--- a/net/sctp/stream_sched.c
+++ b/net/sctp/stream_sched.c
@@ -124,7 +124,7 @@ static struct sctp_sched_ops sctp_sched_fcfs = {
 extern struct sctp_sched_ops sctp_sched_prio;
 extern struct sctp_sched_ops sctp_sched_rr;
 
-struct sctp_sched_ops *sctp_sched_ops[] = {
+static struct sctp_sched_ops *sctp_sched_ops[] = {
 	&sctp_sched_fcfs,
 	&sctp_sched_prio,
 	&sctp_sched_rr,
-- 
2.14.1
