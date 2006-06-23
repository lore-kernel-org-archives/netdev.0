From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH REPOST 1/2] Network Event Notifier Mechanism.
Date: Fri, 23 Jun 2006 13:56:42 -0700 (PDT)
Message-ID: <20060623.135642.48528981.davem@davemloft.net>
References: <20060623201928.32482.69191.stgit@stevo-desktop>
	<20060623.132647.39159829.davem@davemloft.net>
	<1151094895.7808.87.camel@stevo-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:64999
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1752047AbWFWU4o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 16:56:44 -0400
To: swise@opengridcomputing.com
In-Reply-To: <1151094895.7808.87.camel@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steve Wise <swise@opengridcomputing.com>
Date: Fri, 23 Jun 2006 15:34:55 -0500

> But what about the redirect event?  It really needs to pass two bits of
> info:  The old dst_entry ptr and the new dst_entry ptr.  This is needed
> so the rdma driver can figure out which connections now need to use the
> new dst_entry...

struct foo_event_data {
	struct whatever a;
	struct thistoo b;
};

	struct foo_event_data x;

	x->a = xxx;
	x->b = yyy;

	event->data = (void *) &x;
	send_event(&event);

Why do you need typed data to do this?
