From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next? 1/1] netlabel: return msg overflow error from
 netlbl_cipsov4_list faster
Date: Mon, 14 Jul 2008 22:29:15 -0700 (PDT)
Message-ID: <20080714.222915.159608599.davem@davemloft.net>
References: <1215773149-27728-1-git-send-email-den@openvz.org>
	<200807110701.05377.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: den@openvz.org, netdev@vger.kernel.org
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56501
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752748AbYGOF3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 01:29:14 -0400
In-Reply-To: <200807110701.05377.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul.moore@hp.com>
Date: Fri, 11 Jul 2008 07:01:05 -0400

> On Friday 11 July 2008 6:45:49 am Denis V. Lunev wrote:
> > Currently, we are trying to place the information from the kernel to
> > 1, 2, 3 and 4 pages sequentially. These pages are allocated via slab.
> > Though, from the slab point of view steps 3 and 4 are equivalent on
> > most architectures. So, lets skip 3 pages attempt.
> >
> > By the way, should we switch from .doit to .dumpit interface here?
> > The amount of data seems quite big for me.
> >
> > Signed-off-by: Denis V. Lunev <den@openvz.org>
> 
> I'll add my ack to this patch because your logic sounds reasonable and 
> I'm glad to have more eyes on the code :)
> 
> However, I not a big fan of converting this from a .doit to a .dumpit 
> interface because this would cause userspace breakage.  We could 
> potentially do both for backwards compatibility but I have no idea if 
> it is possible to have both interfaces available at the same time.  One 
> thing to keep in mind before diving into your favorite editor is that 
> I've yet to hear of there being a problem with this NetLabel command 
> and the .doit interface, we may want to hold off to see if it becomes 
> an issue.
> 
> Acked-by: Paul Moore <paul.moore@hp.com>

I've applied Denis's patch.

Also, I agree with him that a .dumpit conversion might be
entirely appropriate.
