From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v1 1/2] bridge: export port_no and port_id via
 IFA_INFO_DATA
Date: Fri, 30 Nov 2012 10:18:14 +0000
Message-ID: <20121130101814.GD30697@casper.infradead.org>
References: <1354269514-1863-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:41663 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752269Ab2K3KSS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 05:18:18 -0500
Content-Disposition: inline
In-Reply-To: <1354269514-1863-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/30/12 at 05:58pm, Cong Wang wrote:
> @@ -168,6 +172,8 @@ static const struct nla_policy ifla_brport_policy[IFLA_BRPORT_MAX + 1] = {
>  	[IFLA_BRPORT_MODE]	= { .type = NLA_U8 },
>  	[IFLA_BRPORT_GUARD]	= { .type = NLA_U8 },
>  	[IFLA_BRPORT_PROTECT]	= { .type = NLA_U8 },
> +	[IFLA_BRPORT_NO]	= { .type = NLA_U16 },
> +	[IFLA_BRPORT_ID]	= { .type = NLA_U16 },
>  };
>  
>  /* Change the state of the port and notify spanning tree */

I missed this in the first round. Not much of a point in adding policy
entries if the attributes are read-only as in this case.
