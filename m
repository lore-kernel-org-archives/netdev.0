From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC V2 PATCH] rtnetlink: Add method to calculate dump info
 data size
Date: Mon, 9 May 2011 15:45:27 -0700
Message-ID: <20110509154527.28a72365@nehalam>
References: <20110509222629.8689.77365.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	davem@davemloft.net
To: Greg Rose <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34520 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932389Ab1EIWpa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2011 18:45:30 -0400
In-Reply-To: <20110509222629.8689.77365.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 09 May 2011 15:26:29 -0700
Greg Rose <gregory.v.rose@intel.com> wrote:

> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -56,6 +56,7 @@
>  struct rtnl_link {
>  	rtnl_doit_func		doit;
>  	rtnl_dumpit_func	dumpit;
> +	rtnl_calcit_func calcit;
>  };

Minor nit, why not line up the columns like the other two?

-- 
