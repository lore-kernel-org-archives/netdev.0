From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH net-next-2.6 1/8 v2] sctp: delete unused macro definition
 of sctp_chunk_is_control
Date: Tue, 19 Apr 2011 13:19:29 +0800
Message-ID: <4DAD1B61.6080504@cn.fujitsu.com>
References: <4DAD18AB.3040401@cn.fujitsu.com> <4DAD1915.70503@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60187 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752357Ab1DSFT1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2011 01:19:27 -0400
In-Reply-To: <4DAD1915.70503@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>

The macro never be used.
And if needed, can use !sctp_chunk_is_data instead of.

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
Sorry for missing 'From ...' in the first version
---
 include/net/sctp/constants.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index c70d8cc..deac13d 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -150,7 +150,6 @@ SCTP_SUBTYPE_CONSTRUCTOR(OTHER,		sctp_event_other_t,	other)
 SCTP_SUBTYPE_CONSTRUCTOR(PRIMITIVE,	sctp_event_primitive_t,	primitive)
 
 
-#define sctp_chunk_is_control(a) (a->chunk_hdr->type != SCTP_CID_DATA)
 #define sctp_chunk_is_data(a) (a->chunk_hdr->type == SCTP_CID_DATA)
 
 /* Calculate the actual data size in a data chunk */
-- 
1.6.5.2


