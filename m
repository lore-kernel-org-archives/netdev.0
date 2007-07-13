From: Cruise Huang <zyziii@tom.com>
Subject: a question about the "reord"
Date: Fri, 13 Jul 2007 15:26:28 +0800
Message-ID: <46972924.9020605@tom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpr1.tom.com ([202.108.255.195]:34995 "HELO tom.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1759033AbXGMH5l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jul 2007 03:57:41 -0400
Received: from [192.168.9.92] (unknown [172.24.140.62])
	by bjapp32 (Coremail) with SMTP id S4ABnE8pl0YmAIw+.1
	for <netdev@vger.kernel.org>; Fri, 13 Jul 2007 15:27:21 +0800 (CST)
Received: from 192.168.9.92([210.22.111.234])
	by bjapp22.tom.com(KBAS Gateway 2.1 2.125e) with ESMTP id local22747.1184311631 for <netdev@vger.kernel.org>;
	Fri Jul 13 15:27:11 2007 +0800
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear all:
I'm reading the code about the Congestion Control.Now I'm confused about
the variable "reord" in the function tcp_sacktag_write_queue().

The "reord" is initialized as the tp->packets_out, I think, which is a
max threshold of the reordering.

If it detect a hole or D-SACK ,set the reord to :
---> reord = min(fack_count, reord);

Finally,the code may update the reordering by:
---> tcp_update_reordering(sk, ((tp->fackets_out + 1) - reord), 0);

The questions are :
<1> What's the purpose of the "reord" ?
<2> Why use the "((tp->fackets_out + 1) - reord)" to update the reordering.

Do I need to study some more RFC about this ? If yes,please tell me
,thanks .


