From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] net: Fix race condition when removing qdisc
Date: Thu, 03 Mar 2016 16:37:55 -0800
Message-ID: <1457051875.2761.4.camel@edumazet-ThinkPad-T530>
References: <1456874197-3036009-1-git-send-email-tom@herbertland.com>
	 <CAM_iQpWxkd16A_=htGxjA6OVBj_kzBZKsOF-JmsQQLbJc=r_WA@mail.gmail.com>
	 <CALx6S36-LNu_uqPP3is1U7gO48qtbkTADgxpm_ecuHN+UuxrgQ@mail.gmail.com>
	 <1457049168.2761.3.camel@edumazet-ThinkPad-T530>
	 <CALx6S34tWHZQJfTCc6vDkgDbo1DDFP33LNFnMJ591QEW87YAmA@mail.gmail.com>
	 <CALx6S34KqhnaXeMiii2kxWdV0h3FVK4dst=Lhg7OxAvLRZLshQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Lawrence Brakmo <brakmo@fb.com>,
	Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:33857 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751690AbcCDAh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 19:37:58 -0500
Received: by mail-pf0-f171.google.com with SMTP id 4so24450849pfd.1
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 16:37:58 -0800 (PST)
In-Reply-To: <CALx6S34KqhnaXeMiii2kxWdV0h3FVK4dst=Lhg7OxAvLRZLshQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On jeu., 2016-03-03 at 16:24 -0800, Tom Herbert wrote:

> I suppose that case is protected by est_lock and e->bstats == NULL.

Yes, c7de2cf053420d63bac85133469c965d4b1083e1 was supposed
to fix some issues ...
