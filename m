From: Eric Dumazet <edumazet@google.com>
Subject: Re: use-after-free in sctp_do_sm
Date: Thu, 3 Dec 2015 06:48:45 -0800
Message-ID: <CANn89iKEv-q6EFi1eX+Hk_2+jNfZ0ayUqUn_Fh1U7RTs9xjdXg@mail.gmail.com>
References: <CACT4Y+ZnWRZfQC25uW=GXHAJB=GX0L6tJQUy43P6WNR3=hwT8Q@mail.gmail.com>
	<20151203130525.GB4164@mrl.redhat.com>
	<CACT4Y+ZMshfGvb81VhCGuZzbSec2sCBaJUNFb1QQ-ccyH9BPkQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:36883 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964954AbbLCOsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 09:48:46 -0500
Received: by wmww144 with SMTP id w144so25292703wmw.0
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2015 06:48:45 -0800 (PST)
In-Reply-To: <CACT4Y+ZMshfGvb81VhCGuZzbSec2sCBaJUNFb1QQ-ccyH9BPkQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> No, I don't. But pr_debug always computes its arguments. See no_printk
> in printk.h. So this use-after-free happens for all users.

Hmm.

pr_debug() should be a nop unless either DEBUG or CONFIG_DYNAMIC_DEBUG are set

On our production kernels, pr_debug() is a nop.

Can you double check ? Thanks !
