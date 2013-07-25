From: Dominique Martinet <dominique.martinet@cea.fr>
Subject: Re: [V9fs-developer] [PATCH] net: trans_rdma: remove unused
 function
Date: Thu, 25 Jul 2013 08:14:11 +0200
Message-ID: <20130725061411.GA8579@nautica>
References: <1374497956-32104-1-git-send-email-andi@etezian.org>
 <20130724.154646.2283898956674234778.davem@davemloft.net>
 <1374707387.29835.23.camel@x61.thuisdomein>
 <20130724.164514.393667021861625699.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: pebolle@tiscali.nl, lucho@ionkov.net, ericvh@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	andi@etezian.org, v9fs-developer@lists.sourceforge.net,
	rminnich@sandia.gov
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nautica.notk.org ([91.121.71.147]:42822 "EHLO nautica.notk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753005Ab3GYGUt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jul 2013 02:20:49 -0400
Content-Disposition: inline
In-Reply-To: <20130724.164514.393667021861625699.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

David Miller wrote on Wed, Jul 24, 2013 :
> From: Paul Bolle <pebolle@tiscali.nl>
> Date: Thu, 25 Jul 2013 01:09:47 +0200
> > After this patch one might as well revert the rest of commit
> > 80b45261a0b2 ("9P: Add cancelled() to the transport functions.") too. It
> > seems the entire cancelled callback stuff is now pointless.
> > 
> > As I already asked in https://lkml.org/lkml/2013/7/15/87 : did that
> > commit "forget to actually hook up rdma_cancelled() into
> > p9_rdma_trans()?". It does look so to me.
> 
> If nobody responds to this in the next day or so, feel free to send me
> a patch which rips it all out.
> 
> No response means they don't care, and neither, therefore, should we.

Well, I do care - but I couldn't find where the trans->cancelled member
function was supposed to be called anyway...
So adding it to the struct and fixing the warning is well and fine, but
if it's still never called in the end I don't see much point and there's
nothing to test.

It's on my loooong todo list of things to look at, but as no other reply
came and the patch was never picked up it kind of dropped in priority.
I'll have another look next week

I guess the worst that could happen would be submitting the
rdma_cancelled function again when this is sorted out :)

Regards,
-- 
Dominique Martinet
