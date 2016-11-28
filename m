From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] bpf: cgroup: fix documentation of __cgroup_bpf_update()
Date: Mon, 28 Nov 2016 14:03:21 +0100
Message-ID: <583C2B19.7010506@iogearbox.net>
References: <1480331099-20216-1-git-send-email-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, roszenrami@gmail.com,
        cgroups@vger.kernel.org
To: Daniel Mack <daniel@zonque.org>, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57507 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753790AbcK1ND2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 08:03:28 -0500
In-Reply-To: <1480331099-20216-1-git-send-email-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/2016 12:04 PM, Daniel Mack wrote:
> There's a 'not' missing in one paragraph. Add it.
>
> Signed-off-by: Daniel Mack <daniel@zonque.org>
> Reported-by: Rami Rosen <roszenrami@gmail.com>
> Fixes: 3007098494be ("cgroup: add support for eBPF programs")

Small nit in subject: s/[PATCH]/[PATCH net-next]/

>   kernel/bpf/cgroup.c | 6 +++---
>   1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/kernel/bpf/cgroup.c b/kernel/bpf/cgroup.c
> index a0ab43f..b708e6e 100644
> --- a/kernel/bpf/cgroup.c
> +++ b/kernel/bpf/cgroup.c
> @@ -70,9 +70,9 @@ void cgroup_bpf_inherit(struct cgroup *cgrp, struct cgroup *parent)
>    * releases the one that is currently attached, if any. @prog is then made
>    * the effective program of type @type in that cgroup.
>    *
> - * If @prog is %NULL, the currently attached program of type @type is released,
> - * and the effective program of the parent cgroup (if any) is inherited to
> - * @cgrp.
> + * If @prog is not %NULL, the currently attached program of type @type is
> + * released, and the effective program of the parent cgroup (if any) is
> + * inherited to @cgrp.

Both paragraphs for __cgroup_bpf_update() currently say:

[...]
  * If @prog is %NULL, this function attaches a new program to the cgroup and
  * releases the one that is currently attached, if any. @prog is then made
  * the effective program of type @type in that cgroup.
  *
  * If @prog is %NULL, the currently attached program of type @type is released,
  * and the effective program of the parent cgroup (if any) is inherited to
  * @cgrp.
[...]

It looks to me that you are 'fixing' the wrong location. First paragraph is
actually missing a "not", which would then also align with what the code does.
