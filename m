From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH v5 0/3] RDS: RDS-core fixes
Date: Wed,  8 Apr 2015 09:46:08 -0400
Message-ID: <cover.1428500006.git.sowmini.varadhan@oracle.com>
Cc: chien.yen@oracle.com, davem@davemloft.net,
	rds-devel@oss.oracle.com, agrover@redhat.com, clm@fb.com,
	zab@zabbo.net, ajaykumar.hotchandani@oracle.com,
	sergei.shtylyov@cogentembedded.com,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch-series updates the RDS core and rds-tcp modules with
some bug fixes that were originally authored by  Andy Grover,
Zach Brown, and Chris Mason.

v5: Clarify comment per http://www.spinics.net/lists/netdev/msg324220.html

Sowmini Varadhan (3):
  Document AF_RDS, PF_RDS and SOL_RDS correctly.
  RDS: only use passive connections when addresses match
  RDS: make sure not to loop forever inside rds_send_xmit

 Documentation/networking/rds.txt |    9 ++++-----
 net/rds/connection.c             |    3 ++-
 net/rds/rds.h                    |    1 +
 net/rds/send.c                   |   33 +++++++++++++++++++++++++++++++--
 4 files changed, 38 insertions(+), 8 deletions(-)
