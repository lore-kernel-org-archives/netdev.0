From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [ofa-general] Re: [PATCH 06/21] RDS: Connection handling
Date: Thu, 29 Jan 2009 11:03:30 +0300
Message-ID: <20090129080330.GB12197@ioremap.net>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com> <1233022678-9259-7-git-send-email-andy.grover@oracle.com> <20090127133418.GH2646@ioremap.net> <200901271447.29377.oliver@neukum.org> <497F3640.6070600@opengridcomputing.com> <c0a09e5c0901281903m2d6804e0u94f1e1bc9792b56b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Wise <swise@opengridcomputing.com>,
	Oliver Neukum <oliver@neukum.org>, netdev@vger.kernel.org,
	rdreier@cisco.com, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org
To: Andrew Grover <andy.grover@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kandzendo.ru ([195.178.208.66]:44489 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751988AbZA2IDn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jan 2009 03:03:43 -0500
Content-Disposition: inline
In-Reply-To: <c0a09e5c0901281903m2d6804e0u94f1e1bc9792b56b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 28, 2009 at 07:03:49PM -0800, Andrew Grover (andy.grover@gmail.com) wrote:
> What's the best way to fix this?
> 
> This is all so rds-info can print out a nice list of connections, and
> if they're sending or not. I don't see an easy way to fix this. A
> _trylock-like function that didn't grab it would be nice? I can always
> just not report this particular bit of info, that actually might be
> easiest.

You use atomic variables for the other cases, add another one here to
mark locked connection. Looks ugly but does not crash at least.

-- 
	Evgeniy Polyakov
