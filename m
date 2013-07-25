From: Dominique Martinet <dominique.martinet@cea.fr>
Subject: Re: [V9fs-developer] [PATCH] net: trans_rdma: remove unused
 function
Date: Thu, 25 Jul 2013 08:48:02 +0200
Message-ID: <20130725064802.GA12569@nautica>
References: <1374497956-32104-1-git-send-email-andi@etezian.org>
 <20130724.154646.2283898956674234778.davem@davemloft.net>
 <1374707387.29835.23.camel@x61.thuisdomein>
 <20130724.164514.393667021861625699.davem@davemloft.net>
 <20130725061411.GA8579@nautica>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: pebolle@tiscali.nl, lucho@ionkov.net, ericvh@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	andi@etezian.org, v9fs-developer@lists.sourceforge.net,
	rminnich@sandia.gov
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130725061411.GA8579@nautica>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hard morning, sorry for the double mail.

Dominique Martinet wrote on Thu, Jul 25, 2013 :
> Well, I do care - but I couldn't find where the trans->cancelled member
> function was supposed to be called anyway...
> So adding it to the struct and fixing the warning is well and fine, but
> if it's still never called in the end I don't see much point and there's
> nothing to test.

To be more precise, there's a single call to c->trans_mode->cancelled in
net/9p/client.c, in p9_client_flush, which is called on subfunction returning
-ERESTARTSYS... which never happens as far as I could see.

This will be useful once/if we start working on client recovery, though
- so the function in itself definitely does interest me, and I guess
that thinking about I would have preferred to have the hook added rather
than the function removed.
But there definitely is no hurry to add this cancelled function till
then.


Regards,
-- 
Dominique Martinet
