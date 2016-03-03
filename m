From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] net: Fix race condition when removing qdisc
Date: Thu, 03 Mar 2016 15:52:48 -0800
Message-ID: <1457049168.2761.3.camel@edumazet-ThinkPad-T530>
References: <1456874197-3036009-1-git-send-email-tom@herbertland.com>
	 <CAM_iQpWxkd16A_=htGxjA6OVBj_kzBZKsOF-JmsQQLbJc=r_WA@mail.gmail.com>
	 <CALx6S36-LNu_uqPP3is1U7gO48qtbkTADgxpm_ecuHN+UuxrgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Lawrence Brakmo <brakmo@fb.com>,
	Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36409 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751515AbcCCXwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 18:52:51 -0500
Received: by mail-pa0-f44.google.com with SMTP id fi3so21526819pac.3
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 15:52:50 -0800 (PST)
In-Reply-To: <CALx6S36-LNu_uqPP3is1U7gO48qtbkTADgxpm_ecuHN+UuxrgQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On jeu., 2016-03-03 at 14:24 -0800, Tom Herbert wrote:
> This a kernel based on 3.10. We believe the lockups coincide with
> removing/readding qdiscs.

You could backport 64153ce0a7b61b2a
("net_sched: htb: do not setup default rate estimators"),
unless you desperately want these rate estimators...

How many HTB classes do you deal with ?
