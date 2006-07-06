From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 0/3] Action API fixes
Date: Thu, 06 Jul 2006 08:27:34 -0400
Message-ID: <1152188854.5103.17.camel@jzny2>
References: <20060704220504.787776000@postel.suug.ch>
	 <20060705.204751.112605889.davem@davemloft.net>
	 <1152187428.5103.6.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-+3pSczIjmegyINs8lXiP"
Cc: tgraf@suug.ch, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:57772 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1030224AbWGFM1j
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jul 2006 08:27:39 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FySxJ-0002sP-CF
	for netdev@vger.kernel.org; Thu, 06 Jul 2006 08:27:41 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <1152187428.5103.6.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-+3pSczIjmegyINs8lXiP
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2006-06-07 at 08:03 -0400, jamal wrote:
> On Wed, 2006-05-07 at 20:47 -0700, David Miller wrote:
> > From: Thomas Graf <tgraf@suug.ch>
> > Date: Wed, 05 Jul 2006 00:05:04 +0200
> > 
> > > Fixes for some rather serious action API bugs. Please apply.
> > 
> > All applied, I'll push to -stable, thanks Thomas.
> 
> Dave, Did you actually read my comments on the patches? 
> One patch deserved to go to stable and one was the wrong fix.
> 
> Should i now send a patch against the one?

The proper patch is attached as a replacement for 
"[PATCH 3/3] [PKT_SCHED]: Fix error handling while dumping action"
from Thomas. 
If you have already submitted it, then i will send a patch against it.

cheers,
jamal

--=-+3pSczIjmegyINs8lXiP
Content-Disposition: attachment; filename=nerr-act
Content-Type: text/plain; name=nerr-act; charset=utf-8
Content-Transfer-Encoding: 7bit


Fix dumping possibly returning a positive code
Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
---

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 2ffa11c..0477c7a 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -259,7 +259,7 @@ tcf_action_dump(struct sk_buff *skb, str
 
 rtattr_failure:
 	skb_trim(skb, b - skb->data);
-	return -err;
+	return -1;
 }
 
 struct tc_action *tcf_action_init_1(struct rtattr *rta, struct rtattr *est,

--=-+3pSczIjmegyINs8lXiP--

