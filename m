From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next 1/2] net_sched: move tc_action into tcf_common
Date: Thu, 21 Jul 2016 03:38:21 -0400
Message-ID: <1ce68bcb-7a73-013c-bdd7-639dce465ea7@mojatatu.com>
References: <1469078614-13540-1-git-send-email-xiyou.wangcong@gmail.com>
 <1469078614-13540-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:35200 "EHLO
	mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751126AbcGUHiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 03:38:24 -0400
Received: by mail-qt0-f196.google.com with SMTP id q11so3411868qtb.2
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 00:38:24 -0700 (PDT)
In-Reply-To: <1469078614-13540-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is an involved change (and i was fond of the container_of()
trickery;)).

Looking at this patch I cant grok some parts - maybe i need to apply it
when i am not in a hurry to see clearly.
Mostly this around things like:
---
const struct tc_action *a
struct tcf_mirred *m = to_mirred(a)
---

Essentially this reduces to
struct tcf_mirred *m = (struct tcf_mirred *)a

How would that work?
Do we still need the void *priv

cheers,
jamal
