From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH v2] connector: add an event for monitoring process
 tracers
Date: Mon, 18 Jul 2011 20:15:58 +0400
Message-ID: <20110718161558.GA366@ioremap.net>
References: <1310751918-31579-1-git-send-email-vzapolskiy@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oleg Nesterov <oleg@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Vladimir Zapolskiy <vzapolskiy@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intermatrixgroup.ru ([195.178.208.66]:44288 "EHLO
	tservice.net.ru" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753150Ab1GRQQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 12:16:02 -0400
Content-Disposition: inline
In-Reply-To: <1310751918-31579-1-git-send-email-vzapolskiy@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Fri, Jul 15, 2011 at 08:45:18PM +0300, Vladimir Zapolskiy (vzapolskiy@gmail.com) wrote:
> This version of the change extends proc_ptrace_connector() argument
> list, so it becomes possible to specify a ptrace request eliminating
> process attach/detach race.
> 
> Also tracehook_tracer_task() function was renamed to ptrace_parent(),
> but as far as proc_ptrace_connector(task, PTRACE_ATTACH) is called
> from a tracer process itself, it becomes possible to get rid of that
> call usage completely.
> 
> Oleg, I've rebased the change, and if you don't have objections, I'd
> be glad, if you can apply this change upon your ptrace branch, thank
> you in advance.

I still ack this one :)
Acked-by: Evgeniy Polyakov <zbr@ioremap.net>

-- 
	Evgeniy Polyakov
