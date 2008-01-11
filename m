From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: TCP & hints
Date: Fri, 11 Jan 2008 23:50:55 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0801112348290.20859@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48029 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762824AbYAKVu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 16:50:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

Do you still remember what this is for (got added along with other TCP 
hint stuff)? What kind of problem you saw back then (or who saw
problems)?

@@ -1605,6 +1711,10 @@ static void tcp_undo_cwr(struct sock *sk, const int 
undo)
        }
        tcp_moderate_cwnd(tp);
        tp->snd_cwnd_stamp = tcp_time_stamp;
+
+       /* There is something screwy going on with the retrans hints after
+          an undo */
+       clear_all_retrans_hints(tp);
 }
 
 static inline int tcp_may_undo(struct tcp_sock *tp)


-- 
 i.
