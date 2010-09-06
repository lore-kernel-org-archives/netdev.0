From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: fix sleep inside atomic
Date: Mon, 06 Sep 2010 13:11:07 -0700 (PDT)
Message-ID: <20100906.131107.183045782.davem@davemloft.net>
References: <1283742379-9610-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54477
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755106Ab0IFUKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 16:10:50 -0400
In-Reply-To: <1283742379-9610-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Mon,  6 Sep 2010 05:06:19 +0200

> We cannot use spinlock when kmalloc is invoked with
> GFP_KERNEL flag because it can sleep.
> So this patch reviews the usage of spinlock within the
> stmmac_resume function avoing this bug.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied, but you are extremely guilty of the sin of omission
here.

Why in the world did you not at least CC: Jiri, the person
who reported this problem?  You should do that at a minimum
when someone reports a problem with code you are fixing.

And in this case he definitely deserves a

Reported-by:

tag in the commit message as well.

Please don't fail to acknowledge a reporter's efforts like
this ever again.
