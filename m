From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 0/2] net_sched: bug fixes for ife action
Date: Mon, 20 Jun 2016 13:37:17 -0700
Message-ID: <1466455039-23268-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: khoroshilov@ispras.ru, Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:33344 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752733AbcFTUwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 16:52:12 -0400
Received: by mail-pa0-f67.google.com with SMTP id ts6so11646082pac.0
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 13:52:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang (2):
  act_ife: only acquire tcf_lock for existing actions
  act_ife: acquire ife_mod_lock before reading ifeoplist

 include/net/tc_act/tc_ife.h |  6 ++---
 net/sched/act_ife.c         | 53 ++++++++++++++++++++++++++-------------------
 2 files changed, 34 insertions(+), 25 deletions(-)

-- 
2.1.0
