From: jamal <hadi@cyberus.ca>
Subject: [PATCH][XFRM]: Convert a few __u8 to proper u8
Date: Fri, 17 Nov 2006 11:59:31 -0500
Message-ID: <1163782771.5219.9.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-+zNf8xUb+QjtgUtKMGD+"
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:9889 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S933733AbWKQQ7d
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Nov 2006 11:59:33 -0500
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1Gl73x-0006Gs-LF
	for netdev@vger.kernel.org; Fri, 17 Nov 2006 11:59:37 -0500
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-+zNf8xUb+QjtgUtKMGD+
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Ok, here it is. 2.6.20 material but dependent on all the other patches
I have posted.

Ok, this ipsec thing is distracting me from the 2 generic netlink
presentations i am trying to get started on for Foss.in (For once i
thought i was organized - worse, Harald will kill me if i dont have it
done).
Actually i still have one more on aevents that i wanted to talk about;
but maybe i should leave that to later.

cheers,
jamal

--=-+zNf8xUb+QjtgUtKMGD+
Content-Disposition: attachment; filename=ipsec-subp4
Content-Type: text/plain; name=ipsec-subp4; charset=UTF-8
Content-Transfer-Encoding: 7bit

[XFRM]: Convert a few __u8 to proper u8

Caught by the EyeBalls(tm) of Thomas Graf

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit 7f80e98b11a207aaa38d33128ecc16a09b4cb278
tree e72067360b95c65373a4fd227c4424f144625241
parent eb52e3df145c2f8676da51a21cbe664d7794949c
author Jamal Hadi Salim <hadi@cyberus.ca> Fri, 17 Nov 2006 11:53:29 -0500
committer Jamal Hadi Salim <hadi@jzny2.(none)> Fri, 17 Nov 2006 11:53:29 -0500

 net/xfrm/xfrm_user.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 793b241..6b85493 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -772,7 +772,7 @@ out_noput:
 	return err;
 }
 
-static int verify_policy_dir(__u8 dir)
+static int verify_policy_dir(u8 dir)
 {
 	switch (dir) {
 	case XFRM_POLICY_IN:
@@ -787,7 +787,7 @@ static int verify_policy_dir(__u8 dir)
 	return 0;
 }
 
-static int verify_policy_type(__u8 type)
+static int verify_policy_type(u8 type)
 {
 	switch (type) {
 	case XFRM_POLICY_TYPE_MAIN:
@@ -900,7 +900,7 @@ static int copy_from_user_policy_type(u8
 {
 	struct rtattr *rt = xfrma[XFRMA_POLICY_TYPE-1];
 	struct xfrm_userpolicy_type *upt;
-	__u8 type = XFRM_POLICY_TYPE_MAIN;
+	u8 type = XFRM_POLICY_TYPE_MAIN;
 	int err;
 
 	if (rt) {
@@ -1082,7 +1082,7 @@ static inline int copy_to_user_sec_ctx(s
 }
 
 #ifdef CONFIG_XFRM_SUB_POLICY
-static int copy_to_user_policy_type(__u8 type, struct sk_buff *skb)
+static int copy_to_user_policy_type(u8 type, struct sk_buff *skb)
 {
 	struct xfrm_userpolicy_type upt;
 
@@ -1098,7 +1098,7 @@ rtattr_failure:
 }
 
 #else
-static inline int copy_to_user_policy_type(__u8 type, struct sk_buff *skb)
+static inline int copy_to_user_policy_type(u8 type, struct sk_buff *skb)
 {
 	return 0;
 }
@@ -1189,7 +1189,7 @@ static int xfrm_get_policy(struct sk_buf
 {
 	struct xfrm_policy *xp;
 	struct xfrm_userpolicy_id *p;
-	__u8 type = XFRM_POLICY_TYPE_MAIN;
+	u8 type = XFRM_POLICY_TYPE_MAIN;
 	int err;
 	struct km_event c;
 	int delete;
@@ -1407,7 +1407,7 @@ out:
 static int xfrm_flush_policy(struct sk_buff *skb, struct nlmsghdr *nlh, void **xfrma)
 {
 	struct km_event c;
-	__u8 type = XFRM_POLICY_TYPE_MAIN;
+	u8 type = XFRM_POLICY_TYPE_MAIN;
 	int err;
 
 	err = copy_from_user_policy_type(&type, (struct rtattr **)xfrma);
@@ -1428,7 +1428,7 @@ static int xfrm_add_pol_expire(struct sk
 	struct xfrm_policy *xp;
 	struct xfrm_user_polexpire *up = NLMSG_DATA(nlh);
 	struct xfrm_userpolicy_info *p = &up->pol;
-	__u8 type = XFRM_POLICY_TYPE_MAIN;
+	u8 type = XFRM_POLICY_TYPE_MAIN;
 	int err = -ENOENT;
 
 	err = copy_from_user_policy_type(&type, (struct rtattr **)xfrma);

--=-+zNf8xUb+QjtgUtKMGD+--

