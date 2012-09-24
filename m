From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/3] vxlan: virtual extensible lan
Date: Mon, 24 Sep 2012 21:33:03 +0200
Message-ID: <1348515183.26828.1517.camel@edumazet-glaptop>
References: <20120924184304.727711327@vyatta.com>
	 <20120924185050.162920909@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Chris Wright <chrisw@redhat.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:60735 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755723Ab2IXTdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 15:33:09 -0400
Received: by bkcjk13 with SMTP id jk13so1142768bkc.19
        for <netdev@vger.kernel.org>; Mon, 24 Sep 2012 12:33:07 -0700 (PDT)
In-Reply-To: <20120924185050.162920909@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-24 at 11:43 -0700, Stephen Hemminger wrote:

> --- a/drivers/net/Kconfig	2012-09-24 10:56:57.080291529 -0700
> +++ b/drivers/net/Kconfig	2012-09-24 11:08:02.865416523 -0700
> @@ -149,6 +149,19 @@ config MACVTAP
>  	  To compile this driver as a module, choose M here: the module
>  	  will be called macvtap.
>  
> +config VXLAN
> +       tristate "Virtual eXtensible Local Area Network (VXLAN)"
> +       depends on EXPERIMENTAL
> +       ---help---
> +	  This allows one to create vxlan virtual interfaces that provide
> +	  Layer 2 Networks over Layer 3 Networks. VXLAN is often used
> +	  to tunnel virtual network infrastructure in virtualized environments.
> +	  For more information see:
> +	    http://tools.ietf.org/html/draft-mahalingam-dutt-dcops-vxlan-02
> +
> +	  To compile this driver as a module, choose M here: the module
> +	  will be called macvlan.
> +

copy/paste error, this module wont be called macvlan ;)
