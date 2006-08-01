From: James Morris <jmorris@namei.org>
Subject: Re: [take2 1/4] kevent: core files.
Date: Tue, 1 Aug 2006 09:46:58 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0608010945090.10827@d.namei>
References: <11544248451203@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.sea5.speakeasy.net ([69.17.117.5]:40837 "EHLO
	mail3.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751574AbWHANrC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 09:47:02 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <11544248451203@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 1 Aug 2006, Evgeniy Polyakov wrote:

> +	u->ready_num = 0;
> +#ifdef CONFIG_KEVENT_USER_STAT
> +	u->wait_num = u->im_num = u->total = 0;
> +#endif

Generally, #ifdefs in the body of the kernel code are discouraged.  Can 
you abstract these out as static inlines?


- James
-- 
James Morris
<jmorris@namei.org>
