From: Benjamin Poirier <benjamin.poirier@gmail.com>
Subject: =?UTF-8?q?=5BPATCH=5D=20net=3A=20fix=20typos=20in=20Documentation/networking/scaling=2Etxt?=
Date: Tue,  4 Oct 2011 10:00:30 -0400
Message-ID: <1317736830-4442-1-git-send-email-benjamin.poirier@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-doc@vger.kernel.org, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The second hunk fixes rps_sock_flow_table but has to re-wrap the paragr=
aph.

Signed-off-by: Benjamin Poirier <benjamin.poirier@gmail.com>
---
 Documentation/networking/scaling.txt |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/Documentation/networking/scaling.txt b/Documentation/netwo=
rking/scaling.txt
index 8ce7c30..fe67b5c 100644
--- a/Documentation/networking/scaling.txt
+++ b/Documentation/networking/scaling.txt
@@ -27,7 +27,7 @@ applying a filter to each packet that assigns it to o=
ne of a small number
 of logical flows. Packets for each flow are steered to a separate rece=
ive
 queue, which in turn can be processed by separate CPUs. This mechanism=
 is
 generally known as =E2=80=9CReceive-side Scaling=E2=80=9D (RSS). The g=
oal of RSS and
-the other scaling techniques to increase performance uniformly.
+the other scaling techniques is to increase performance uniformly.
 Multi-queue distribution can also be used for traffic prioritization, =
but
 that is not the focus of these techniques.
=20
@@ -186,10 +186,10 @@ are steered using plain RPS. Multiple table entri=
es may point to the
 same CPU. Indeed, with many flows and few CPUs, it is very likely that
 a single application thread handles flows with many different flow has=
hes.
=20
-rps_sock_table is a global flow table that contains the *desired* CPU =
for
-flows: the CPU that is currently processing the flow in userspace. Eac=
h
-table value is a CPU index that is updated during calls to recvmsg and
-sendmsg (specifically, inet_recvmsg(), inet_sendmsg(), inet_sendpage()
+rps_sock_flow_table is a global flow table that contains the *desired*=
 CPU
+for flows: the CPU that is currently processing the flow in userspace.
+Each table value is a CPU index that is updated during calls to recvms=
g
+and sendmsg (specifically, inet_recvmsg(), inet_sendmsg(), inet_sendpa=
ge()
 and tcp_splice_read()).
=20
 When the scheduler moves a thread to a new CPU while it has outstandin=
g
--=20
1.7.6.3

