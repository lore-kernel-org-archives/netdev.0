From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [ATM] he: Fix __init/__devinit conflict
Date: Sun, 24 Sep 2006 20:11:18 -0700 (PDT)
Message-ID: <20060924.201118.71090751.davem@davemloft.net>
References: <877j0a5i6v.fsf@digitalvampire.org>
	<87fyeit8wd.fsf@digitalvampire.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:54669
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751375AbWIYDLT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Sep 2006 23:11:19 -0400
To: roland@digitalvampire.org
In-Reply-To: <87fyeit8wd.fsf@digitalvampire.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <roland@digitalvampire.org>
Date: Sat, 23 Sep 2006 17:17:54 -0700

> Dave, this was acked by Chas (and he even requested it go into 2.6.18)
> but it seems to have gotten dropped somewhere -- it's not in Linus's
> tree even after he pulled your net tree.
> 
> Please apply.

Applied.

I was waiting for a resolution in the fact that the copy
Chas posted only had one of the transformations whereas
as you pointed out all of the ones in your original
patch were necessary.

Chas, as a subsystem maintainer, if you change a submitter's patch in
a significant and non-trivial way, you should at least mention a brief
reason why you did that.  In this case, why did you delete all of
Roland's __init/__devinit transformations except one when they all
were necessary to fix this bug?
