From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH 00/13] net_sched: misc cleanups and improvements
Date: Tue,  4 Nov 2014 09:56:23 -0800
Message-ID: <1415123796-8093-1-git-send-email-xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:61852 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751665AbaKDR4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 12:56:46 -0500
Received: by mail-pa0-f48.google.com with SMTP id ey11so14880396pad.21
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 09:56:45 -0800 (PST)
Received: from localhost.net ([8.25.197.27])
        by mx.google.com with ESMTPSA id n2sm1031700pdg.2.2014.11.04.09.56.44
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Nov 2014 09:56:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Minor code cleanups for TC qdiscs and filters, each patch has
more details.

Cong Wang (13):
      net_sched: refactor out tcf_exts
      net_sched: introduce qdisc_peek() helper function
      net_sched: rename ->gso_skb to ->dequeued_skb
      net_sched: rename qdisc_drop() to qdisc_drop_skb()
      net_sched: introduce qdisc_drop() helper function
      net_sched: move some qdisc flag into qdisc ops
      net_sched: move TCQ_F_MQROOT into qdisc ops
      net_sched: use a flag to indicate fifo qdiscs instead of the name
      net_sched: redefine qdisc_create_dflt()
      net_sched: forbid setting default qdisc to inappropriate ones
      net_sched: remove hashmask from Qdisc_class_hash
      net_sched: remove useless qdisc_stab_lock
      net_sched: return NULL instead of ERR_PTR for qdisc_alloc()
