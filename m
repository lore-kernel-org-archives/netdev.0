From: David Miller <davem@davemloft.net>
Subject: Re: Compilation error on freshly pulled net-next?
Date: Fri, 05 Sep 2014 15:09:01 -0700 (PDT)
Message-ID: <20140905.150901.79089716373802484.davem@davemloft.net>
References: <540A2F7F.8060809@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56652 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751187AbaIEWJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 18:09:02 -0400
In-Reply-To: <540A2F7F.8060809@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Fri, 05 Sep 2014 14:47:43 -0700

> Looks like someone slipped a J in there and confused things:
> 
>                + rtnl_port_size(dev, ext_filter_mask) /* IFLA_VF_PORTS +
>                IFLA_PORT_SELF */J + rtnl_link_get_size(dev) /* IFLA_LINKINFO */
>                + rtnl_link_get_af_size(dev) /* IFLA_AF_SPEC */
> 
> (hopefully my mail client won't have mangled things too badly)
> 
> What is odd though is a git diff after I've replaced that 'J' with a
> return isn't giving me any output.

That doesn't exist in my tree.
