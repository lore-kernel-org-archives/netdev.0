From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 5/6] bond: Implement a basic set of rtnl link ops
Date: Fri, 30 Oct 2009 09:29:55 +0100
Message-ID: <4AEAA403.7080204@trash.net>
References: <m1tyxhwxah.fsf@fess.ebiederm.org> <1256861906-5059-5-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37723 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753687AbZJ3IaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 04:30:01 -0400
In-Reply-To: <1256861906-5059-5-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> +static struct rtnl_link_ops bond_link_ops __read_mostly = {
> +	.kind		= "bond",
> +	.setup		= bond_setup,
> +	.validate	= bond_validate,
> +};

One more thing - you need to initialize .priv_size here so
the devices created through rtnl_link have enough private
room allocated.
