From: Dave Hansen <haveblue@us.ibm.com>
Subject: Re: [PATCH][RESEND] drivers/base: export
	(un)register_memory_notifier
Date: Mon, 11 Feb 2008 02:12:23 -0800
Message-ID: <1202724743.8276.2.camel@nimitz.home.sr71.net>
References: <200802111049.05478.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, Jan-Bernd Themann <themann@de.ibm.com>,
	Thomas Klein <osstklei@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Christoph Raisch <raisch@de.ibm.com>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:46696 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752074AbYBKKMY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2008 05:12:24 -0500
In-Reply-To: <200802111049.05478.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-02-11 at 10:49 +0100, Jan-Bernd Themann wrote:
> are you the right person to address this patch to?

You might want to check the top of the file. ;)

> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -52,11 +52,13 @@ int register_memory_notifier(struct notifier_block *nb)
>  {
>          return blocking_notifier_chain_register(&memory_chain, nb);
>  }
> +EXPORT_SYMBOL(register_memory_notifier);
>  
>  void unregister_memory_notifier(struct notifier_block *nb)
>  {
>          blocking_notifier_chain_unregister(&memory_chain, nb);
>  }
> +EXPORT_SYMBOL(unregister_memory_notifier);

Is there a particular reason these can't be GPL?

-- Dave

