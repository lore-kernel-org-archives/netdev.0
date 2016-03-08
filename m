From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next v2 2/3] ipv6: per netns fib6 walkers
Date: Tue, 8 Mar 2016 10:34:39 -0800
Message-ID: <CAM_iQpWTuk+b4qn5D6mBoqKeK14jZqqg3usjx6xDQt30O2VyYQ@mail.gmail.com>
References: <cover.1457443526.git.mkubecek@suse.cz>
	<44802146091ca75be560080eeb8b534a67950072.1457443527.git.mkubecek@suse.cz>
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
Received: from mail-yw0-f178.google.com ([209.85.161.178]:34543 "EHLO
	mail-yw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750747AbcCHSek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 13:34:40 -0500
In-Reply-To: <44802146091ca75be560080eeb8b534a67950072.1457443527.git.mkubecek@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 8, 2016 at 5:44 AM, Michal Kubecek <mkubecek@suse.cz> wrote:
> The IPv6 FIB data structures are separated per network namespace but
> there is still only one global walkers list and one global walker list
> lock. This means changes in one namespace unnecessarily interfere with
> walkers in other namespaces.
>
> Replace the global list with per-netns lists (and give each its own
> lock).
>
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
> ---
> v2: get rid of ifdef in ipv6_route_seq_setup_walk(), pass net from
> callers instead

Reviewed-by: Cong Wang <xiyou.wangcong@gmail.com>
