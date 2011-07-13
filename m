From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] connector: add an event for monitoring process tracers
Date: Wed, 13 Jul 2011 16:48:32 +0400
Message-ID: <20110713124832.GA28307@ioremap.net>
References: <1310502757-32103-1-git-send-email-vzapolskiy@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Oleg Nesterov <oleg@redhat.com>,
	Roland McGrath <roland@redhat.com>, netdev@vger.kernel.org
To: Vladimir Zapolskiy <vzapolskiy@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from genesysrack.ru ([195.178.208.66]:52122 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752002Ab1GMM4P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2011 08:56:15 -0400
Content-Disposition: inline
In-Reply-To: <1310502757-32103-1-git-send-email-vzapolskiy@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vladimir

On Tue, Jul 12, 2011 at 11:32:37PM +0300, Vladimir Zapolskiy (vzapolskiy@gmail.com) wrote:
> This change adds a procfs connector event, which is emitted on every
> successful process tracer attach or detach.
> 
> If some process connects to other one, kernelspace connector reports
> process id and thread group id of both these involved processes. On
> disconnection null process id is returned.
> 
> Such an event allows to create a simple automated userspace mechanism
> to be aware about processes connecting to others, therefore predefined
> process policies can be applied to them if needed.

Looks good to me, thank you.
Acked-by: Evgeniy Polyakov <zbr@ioremap.net>

-- 
	Evgeniy Polyakov
