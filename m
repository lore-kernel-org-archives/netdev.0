From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next] net: xfrm: xfrm_policy: fix inline not at
 beginning of declaration
Date: Wed, 8 Jan 2014 06:55:36 +0100
Message-ID: <20140108055536.GX31491@secunet.com>
References: <1389133227-11086-1-git-send-email-dborkman@redhat.com>
 <20140107.183412.1584306758322996233.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dborkman@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:47598 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754775AbaAHFzj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 00:55:39 -0500
Content-Disposition: inline
In-Reply-To: <20140107.183412.1584306758322996233.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 07, 2014 at 06:34:12PM -0500, David Miller wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Tue,  7 Jan 2014 23:20:27 +0100
> 
> > Fix three warnings related to:
> > 
> >   net/xfrm/xfrm_policy.c:1644:1: warning: 'inline' is not at beginning of declaration [-Wold-style-declaration]
> >   net/xfrm/xfrm_policy.c:1656:1: warning: 'inline' is not at beginning of declaration [-Wold-style-declaration]
> >   net/xfrm/xfrm_policy.c:1668:1: warning: 'inline' is not at beginning of declaration [-Wold-style-declaration]
> > 
> > Just removing the inline keyword is sufficient as the compiler will
> > decide on its own about inlining or not.
> > 
> > Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> 
> Applied.

I have a fix for this warnings in the ipsec-next tree too:

commit 2f3ea9a95c58fd0e4bed18a9c9dfe53739fee3b2
Author: Weilong Chen <chenweilong@huawei.com>
Date:   Tue Dec 24 09:43:50 2013 +0800

    xfrm: checkpatch erros with inline keyword position
    
    Signed-off-by: Weilong Chen <chenweilong@huawei.com>
    Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>


Should I revert it, or do you want to solve the conflict when
I send the ipsec-next pull request?
