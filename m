From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next v2 1/3] ipv6: replace global gc_args with local variable
Date: Tue, 8 Mar 2016 10:25:23 -0800
Message-ID: <CAM_iQpUicnXkfF67rhXD684Rfqbtuexa9J4Lwyy8h04cP3G02A@mail.gmail.com>
References: <cover.1457443526.git.mkubecek@suse.cz>
	<bb59dc573391233b6f0e033f1f7928d9a35f3dd9.1457443526.git.mkubecek@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Martin KaFai Lau <kafai@fb.com>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f175.google.com ([209.85.161.175]:35948 "EHLO
	mail-yw0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751144AbcCHSZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 13:25:24 -0500
In-Reply-To: <bb59dc573391233b6f0e033f1f7928d9a35f3dd9.1457443526.git.mkubecek@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 8, 2016 at 5:44 AM, Michal Kubecek <mkubecek@suse.cz> wrote:
> Global variable gc_args is only used in fib6_run_gc() and functions
> called from it. As fib6_run_gc() makes sure there is at most one
> instance of fib6_clean_all() running at any moment, we can replace
> gc_args with a local variable which will be needed once multiple
> instances (per netns) of garbage collector are allowed.
>
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

Reviewed-by: Cong Wang <xiyou.wangcong@gmail.com>

Thanks.
