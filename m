From: Michal Ludvig <mludvig@suse.cz>
Subject: [PATCH] pfkey_send_new_mapping()
Date: Thu, 01 Apr 2004 14:23:10 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <406C09AE.1030407@suse.cz>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010900040305060608070900"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010900040305060608070900
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

this is a fix for an obvious typo in $SUBJ. Please apply.

Michal Ludvig
-- 
SUSE Labs                    mludvig@suse.cz | Cray is the only computer
(+420) 296.545.373        http://www.suse.cz | that runs an endless loop
Personal homepage http://www.logix.cz/michal | in just four hours.

--------------010900040305060608070900
Content-Type: text/plain;
 name="kernel-newmap-dst.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="kernel-newmap-dst.diff"

diff -rup linux-2.6.4/net/key/af_key.c linux-2.6.4/net/key/af_key.c
--- linux-2.6.4/net/key/af_key.c	2004-04-01 10:00:32.000000000 +0200
+++ linux-2.6.4/net/key/af_key.c	2004-04-01 10:08:57.000000000 +0200
@@ -2636,7 +2636,7 @@ static int pfkey_send_new_mapping(struct
 	addr->sadb_address_len = 
 		(sizeof(struct sadb_address)+sockaddr_size)/
 			sizeof(uint64_t);
-	addr->sadb_address_exttype = SADB_EXT_ADDRESS_SRC;
+	addr->sadb_address_exttype = SADB_EXT_ADDRESS_DST;
 	addr->sadb_address_proto = 0;
 	addr->sadb_address_reserved = 0;
 	if (x->props.family == AF_INET) {

--------------010900040305060608070900--
