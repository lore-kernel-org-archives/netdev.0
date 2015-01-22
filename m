From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net 0/2] Two cls_bpf fixes
Date: Thu, 22 Jan 2015 10:41:00 +0100
Message-ID: <1421919662-21066-1-git-send-email-dborkman@redhat.com>
Cc: jiri@resnulli.us, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48639 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751449AbbAVJlI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 04:41:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Found them while doing a review on act_bpf and going over the
cls_bpf code again. Will also address the first issue in act_bpf
as it needs to be fixed there, too.

Thanks!

Daniel Borkmann (2):
  net: cls_bpf: fix size mismatch on filter preparation
  net: cls_bpf: fix auto generation of per list handles

 net/sched/cls_bpf.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

-- 
1.7.11.7
