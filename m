From: David Howells <dhowells@redhat.com>
Subject: Re: [patch] RxRPC: use copy_to_user() instead of memcpy()
Date: Wed, 20 Mar 2013 10:23:38 +0000
Message-ID: <27098.1363775018@warthog.procyon.org.uk>
References: <20130319225101.GZ9189@mwanda> <20130319.094240.1315516663563952557.davem@davemloft.net> <20130318105503.GA17102@longonot.mountain> <30707.1363701570@warthog.procyon.org.uk>
Cc: dhowells@redhat.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18952 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751918Ab3CTKXn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Mar 2013 06:23:43 -0400
In-Reply-To: <20130319225101.GZ9189@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Carpenter <dan.carpenter@oracle.com> wrote:

> Thanks for the explanation.  I misread the code and then managed to
> trigger an unrelated locking bug and got confused.
> 
> I think there is a spin_unlock(call->lock) missing somewhere on an
> error path.  I have attached a reproducer file.

Are you running with lockdep enabled?  That should catch such things.

David
