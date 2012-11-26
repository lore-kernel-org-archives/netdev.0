From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next:master 20/25] net/dsa: make DSA tagging depend
 on NETDEVICES and !S390
Date: Mon, 26 Nov 2012 18:57:35 +0000
Message-ID: <1353956255.2717.1.camel@bwh-desktop.uk.solarflarecom.com>
References: <50b2f66a.czw+uqRm3Q/zfbER%fengguang.wu@intel.com>
	 <CAKohpo=r2ZTp5uSp_5duc+zwWvkkwr8dMbz+Yn=WC+ngFy3-0g@mail.gmail.com>
	 <50B3B9F6.5060509@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Viresh Kumar <viresh.kumar@linaro.org>,
	kbuild test robot <fengguang.wu@intel.com>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>
To: Randy Dunlap <rdunlap@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:31563 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751345Ab2KZS5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 13:57:42 -0500
In-Reply-To: <50B3B9F6.5060509@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-11-26 at 10:50 -0800, Randy Dunlap wrote:
> From: Randy Dunlap <rdunlap@infradead.org>
> 
> Fix kconfig dependency warning by making DSA support depend on the
> same kconfig symbols that NET_DSA depend on.
> 
> warning: (NET_DSA_TAG_DSA && NET_DSA_TAG_EDSA && NET_DSA_TAG_TRAILER) selects NET_DSA which has unmet direct dependencies (NET && NETDEVICES && !S390)

This perhaps ought to be abstracted into a HAVE_NET_DSA rather than
reepated here.  Also, in net-next NET_DSA still depends on EXPERIMENTAL,
which should be removed.

Ben.

> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
> ---
>  net/dsa/Kconfig |    1 +
>  1 file changed, 1 insertion(+)
> 
> --- linux-next-20121126.orig/net/dsa/Kconfig
> +++ linux-next-20121126/net/dsa/Kconfig
> @@ -9,6 +9,7 @@ config NET_DSA
>  
> 
>  menu "Distributed Switch Architecture support"
> +	depends on NETDEVICES && !S390
>  
>  # tagging formats
>  config NET_DSA_TAG_DSA

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
