From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH 2/2] [IPV6] MIP6: Loadable module support for MIPv6.
Date: Wed, 23 May 2007 11:54:32 +0200
Message-ID: <200705231154.33208.netdev@axxeo.de>
References: <11799066192758-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:32970 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757703AbXEWJyn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 May 2007 05:54:43 -0400
In-Reply-To: <11799066192758-git-send-email-nakam@linux-ipv6.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

nakam@linux-ipv6.org schrieb:
> From: Masahide NAKAMURA <nakam@linux-ipv6.org>
> 
> This patch makes MIPv6 loadable module named "mip6".
> 
> Here is a modprobe.conf(5) example to load it automatically
> when user application uses XFRM state for MIPv6:
> 
> alias xfrm-type-10-43 mip6
> alias xfrm-type-10-60 mip6

What about  MODULE_ALIAS("xfrm-type-10-60") 
and MODULE_ALIAS("xfrm-type-10-43") in mip6.c ?

The aliases in modprobe.conf(5) should not be necessary then.

If you are really ambitious you can even define a 
MODULE_ALIAS_XFRM_TYPE macro in include/net/xfrm.h
simliar to to MODULE_ALIAS_XFRM_MODE.

Please be sure to discuss CC Herbert Xu then.


Best regards

Ingo Oeser
