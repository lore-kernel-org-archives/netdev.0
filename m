From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH 4/6] bpf: hash: convert per-hashtable lock into per-bucket
 bit spinlock
Date: Wed, 16 Dec 2015 14:58:08 +0800
Message-ID: <CACVXFVOeh0D+Nf8AVw68-e-aSYtVVLiRoUoDCi89zYXXiUm4gA@mail.gmail.com>
References: <1450178464-27721-1-git-send-email-tom.leiming@gmail.com>
	<1450178464-27721-5-git-send-email-tom.leiming@gmail.com>
	<20151215225118.GA67370@ast-mbp.thefacebook.com>
	<CACVXFVMaRPSHCEi9BpA1R9FnQFhUODc6UVonE_SjiytmL2WAXQ@mail.gmail.com>
	<CAHbLzkpW_seTrs+WgFqsriH5uhG4LMY_jiYC0iRQ-LAdJFiUjw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>
To: Yang Shi <shy828301@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:38361 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932197AbbLPG6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 01:58:10 -0500
In-Reply-To: <CAHbLzkpW_seTrs+WgFqsriH5uhG4LMY_jiYC0iRQ-LAdJFiUjw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 16, 2015 at 1:01 PM, Yang Shi <shy828301@gmail.com> wrote:

>
> I recalled Steven confirmed raw_spin_lock has the lockdep benefit too in the
> patch review for changing to raw lock.
>
> Please check this thread out
>  http://lists.openwall.net/netdev/2015/10/31/7

OK, looks I was wrong about the lockdep benifit, :-(

But for this lock, I think lockdep isn't such important, because it is the
intermost lock, and it can be used just for protecting the bucket list
and nothing else need to be covered.


Thanks,
Ming Lei
