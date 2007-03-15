From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [PATCH] Network Events Connector
Date: Wed, 14 Mar 2007 18:17:51 -0700 (PDT)
Message-ID: <20070314.181751.41635171.davem@davemloft.net>
References: <m2fy875n9q.fsf@cerbere.dyndns.info>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sam@synack.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56313
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1422797AbXCOBR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2007 21:17:56 -0400
In-Reply-To: <m2fy875n9q.fsf@cerbere.dyndns.info>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samir Bellabes <sam@synack.fr>
Date: Thu, 15 Mar 2007 02:05:53 +0100

> +#if 0
> +#define DEBUGP printk
> +#else
> +#define DEBUGP(format, args...)
> +#endif

Please no local debugging macros.

> +static unsigned int is_same_event(struct event one, struct event two) {

Please format functions properly, especially wrt. braces, they don't
belong on the line holding the argument list closing parenthesis:

return_type func_name(args)
{
}

I'm not going to read this any further, please master
Documentation/CodingStyle and resubmit if you want further
review from me.

Thanks.
