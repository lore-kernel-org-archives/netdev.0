From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH 02/21] RDS: Main header file
Date: Tue, 27 Jan 2009 16:05:43 +0300
Message-ID: <20090127130543.GD2646@ioremap.net>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com> <1233022678-9259-3-git-send-email-andy.grover@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rdreier@cisco.com, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org, netdev@vger.kernel.org
To: Andy Grover <andy.grover@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from genesysrack.ru ([195.178.208.66]:34274 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753232AbZA0NF4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2009 08:05:56 -0500
Content-Disposition: inline
In-Reply-To: <1233022678-9259-3-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Mon, Jan 26, 2009 at 06:17:39PM -0800, Andy Grover (andy.grover@oracle.com) wrote:
> +/*
> + * XXX randomly chosen, but at least seems to be unused:
> + * #               18464-18768 Unassigned
> + * We should do better.  We want a reserved port to discourage unpriv'ed
> + * userspace from listening.
> + */
> +#define RDS_PORT	18634
> +

What will happen if some application already uses that port?

> +#ifndef AF_RDS
> +#define AF_RDS          28      /* Reliable Datagram Socket     */
> +#endif
