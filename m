From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH 03/21] RDS: Congestion-handling code
Date: Tue, 27 Jan 2009 16:10:49 +0300
Message-ID: <20090127131049.GE2646@ioremap.net>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com> <1233022678-9259-4-git-send-email-andy.grover@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rdreier@cisco.com, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org, netdev@vger.kernel.org
To: Andy Grover <andy.grover@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from corega.com.ru ([195.178.208.66]:54428 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753091AbZA0NKu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2009 08:10:50 -0500
Content-Disposition: inline
In-Reply-To: <1233022678-9259-4-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 26, 2009 at 06:17:40PM -0800, Andy Grover (andy.grover@oracle.com) wrote:
> +/*
> + * Yes, a global lock.  It's used so infrequently that it's worth keeping it
> + * global to simplify the locking.  It's only used in the following
> + * circumstances:
> + *
> + *  - on connection buildup to associate a conn with its maps

Is this a rare condition? Is this protocol only intended for the
long-living connections and is not suitable for the cases when lots of
them are created and teared down quickly?

-- 
	Evgeniy Polyakov
