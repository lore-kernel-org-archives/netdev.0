From: Junchang Wang <junchangwang@gmail.com>
Subject: Re: [PATCH] net: increase skb->users instead of skb_clone()
Date: Thu, 16 Dec 2010 22:36:11 +0800
Message-ID: <AANLkTikhywOSAO+r7kOuDnkDsgTSM4TTZihsSN8bC09E@mail.gmail.com>
References: <1292479045-3136-1-git-send-email-xiaosuo@gmail.com>
	<AANLkTikdYi-Cs=4UtjJx-X4bW+LSKTQBTcSv23NS2S+S@mail.gmail.com>
	<AANLkTi=DvyuZeWzzi5WJR7AeTZba+U7Vz9cJYR5uRBVc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Xinan Tang <xinan.tang@intel.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:64880 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755523Ab0LPOgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 09:36:17 -0500
Received: by fxm18 with SMTP id 18so3326410fxm.2
        for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 06:36:16 -0800 (PST)
In-Reply-To: <AANLkTi=DvyuZeWzzi5WJR7AeTZba+U7Vz9cJYR5uRBVc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 16, 2010 at 10:12 PM, Changli Gao <xiaosuo@gmail.com> wrote:

>
> This happens when run_filter returns non zero. For your case, only
> small parts of packets match bpf filter.
Hi Changli,
In most cases, I want user-space applications see everything. :)

Thanks.
-- 
--Junchang
