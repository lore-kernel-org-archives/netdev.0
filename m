From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 2/8][ATM]: allow bind() on point-to-multpoint svcs (from Martin Whitaker <martin_whitaker@ntlworld.com>)
Date: Tue, 19 Jul 2005 16:45:08 -0400
Message-ID: <200507192045.j6JKj7kf027191@ginger.cmf.nrl.navy.mil>
Cc: davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks!

[ATM]: allow bind() on point-to-multpoint svcs (from Martin Whitaker <martin_whitaker@ntlworld.com>)

  Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>


---
commit c4029a0d6294a1052353346235320a678add4f41
tree e6de8b582d908c7943242e8725d435f0b1fda20a
parent 73500df545c8763d662192d9749fd8d64209c819
author chas williams <chas@relax.(none)> Tue, 19 Jul 2005 14:50:33 -0400
committer chas williams <chas@relax.(none)> Tue, 19 Jul 2005 14:50:33 -0400

 net/atm/svc.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/atm/svc.c b/net/atm/svc.c
--- a/net/atm/svc.c
+++ b/net/atm/svc.c
@@ -118,10 +118,6 @@ static int svc_bind(struct socket *sock,
 		goto out;
 	}
 	vcc = ATM_SD(sock);
-	if (test_bit(ATM_VF_SESSION, &vcc->flags)) {
-		error = -EINVAL;
-		goto out;
-	}
 	addr = (struct sockaddr_atmsvc *) sockaddr;
 	if (addr->sas_family != AF_ATMSVC) {
 		error = -EAFNOSUPPORT;
