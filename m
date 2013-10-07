From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] static_key: WARN on usage before jump_label_init was
 called
Date: Mon, 7 Oct 2013 11:51:52 -0400
Message-ID: <20131007115152.0964afde@gandalf.local.home>
References: <1381015258-7667-1-git-send-email-hannes@stressinduktion.org>
	<1381015258-7667-4-git-send-email-hannes@stressinduktion.org>
	<20131005200558.3be2f841@gandalf.local.home>
	<20131006001247.GB25076@order.stressinduktion.org>
	<20131006182919.GD9295@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, Jason Baron <jbaron@redhat.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Eric Dumazet <edumazet@google.com>,
	"andi @ firstfloor. org David S. Miller" <davem@davemloft.net>,
	x86@kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cdptpa-outbound-snat.email.rr.com ([107.14.166.225]:26914 "EHLO
	cdptpa-oedge-vip.email.rr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750954Ab3JGPv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 11:51:57 -0400
In-Reply-To: <20131006182919.GD9295@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 6 Oct 2013 20:29:19 +0200
Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:


> diff --git a/lib/jump_label_initialized.c b/lib/jump_label_initialized.c
> new file mode 100644
> index 0000000..a668a40
> --- /dev/null
> +++ b/lib/jump_label_initialized.c
> @@ -0,0 +1,6 @@
> +#include <linux/types.h>
> +#include <linux/cache.h>
> +
> +bool static_key_initialized __read_mostly = false;
> +EXPORT_SYMBOL_GPL(static_key_initialized);
> +

So far, the only thing I don't like about this patch is the creation of
this file for the sole purpose of adding this variable.

Perhaps it can just be added to init/main.c?

-- Steve
