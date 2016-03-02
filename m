From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH RFC] net: Fix race condition when removing qdisc
Date: Tue, 1 Mar 2016 22:34:17 -0800
Message-ID: <CAM_iQpWxkd16A_=htGxjA6OVBj_kzBZKsOF-JmsQQLbJc=r_WA@mail.gmail.com>
References: <1456874197-3036009-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	brakmo@fb.com, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f172.google.com ([209.85.160.172]:34434 "EHLO
	mail-yk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851AbcCBGeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 01:34:18 -0500
Received: by mail-yk0-f172.google.com with SMTP id u9so87786096ykd.1
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 22:34:18 -0800 (PST)
In-Reply-To: <1456874197-3036009-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 1, 2016 at 3:16 PM, Tom Herbert <tom@herbertland.com> wrote:
> We are seeing a number of softlockups occurring with HTB upon removing
> the qdisc. We are still attempting to repro the exact circumstances,
> however looking at the code I'm very suspicious of this block in
> net_tx_action and its interaction with dev_deactivate (called through
> tc_modify_qdisc):


Do you mind to share the stack trace of these soft lockups with us?

Thanks.
