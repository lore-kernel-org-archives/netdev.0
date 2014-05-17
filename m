From: Stephen Hemminger <shemming@brocade.com>
Subject: [PATCH] ipv4: minor spelling fix
Date: Fri, 16 May 2014 20:46:58 -0700
Message-ID: <20140516204658.0602477c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:1303 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755785AbaEQD5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 23:57:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/net/ipv4/devinet.c	2014-05-16 20:27:32.491419991 -0700
+++ b/net/ipv4/devinet.c	2014-05-16 20:40:34.037706771 -0700
@@ -827,7 +827,7 @@ static int inet_rtm_newaddr(struct sk_bu
 	ifa_existing = find_matching_ifa(ifa);
 	if (!ifa_existing) {
 		/* It would be best to check for !NLM_F_CREATE here but
-		 * userspace alreay relies on not having to provide this.
+		 * userspace already relies on not having to provide this.
 		 */
 		set_ifa_lifetime(ifa, valid_lft, prefered_lft);
 		return __inet_insert_ifa(ifa, nlh, NETLINK_CB(skb).portid);
