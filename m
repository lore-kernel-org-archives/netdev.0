From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH 04/21] RDS: Transport code
Date: Tue, 27 Jan 2009 16:18:08 +0300
Message-ID: <20090127131808.GF2646@ioremap.net>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com> <1233022678-9259-5-git-send-email-andy.grover@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rdreier@cisco.com, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org, netdev@vger.kernel.org
To: Andy Grover <andy.grover@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cs-studio.ru ([195.178.208.66]:50004 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753061AbZA0NS0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2009 08:18:26 -0500
Content-Disposition: inline
In-Reply-To: <1233022678-9259-5-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 26, 2009 at 06:17:41PM -0800, Andy Grover (andy.grover@oracle.com) wrote:
> +static LIST_HEAD(transports);
> +static DECLARE_RWSEM(trans_sem);
> +

RDS_ prefix?

> +int rds_trans_register(struct rds_transport *trans)
> +{
> +	BUG_ON(strlen(trans->t_name) + 1 >
> +	       sizeof(((struct rds_info_connection *)0)->transport));
> +

Wow. Why not declare 15 as some constant and put it into rds_transport
structure definition?

> +struct rds_transport *rds_trans_get_preferred(__be32 addr)
> +{
> +	struct rds_transport *trans;
> +	struct rds_transport *ret = NULL;
> +
> +        if (IN_LOOPBACK(ntohl(addr)))
> +                return &rds_loop_transport;
> +

Tabs have run away.

-- 
	Evgeniy Polyakov
