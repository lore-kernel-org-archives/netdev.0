From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Wed, 15 Apr 2009 02:28:09 -0700 (PDT)
Message-ID: <20090415.022809.90182032.davem@davemloft.net>
References: <20090415100937.4b08ce28@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gallatin@myri.com, brice@myri.com
To: sgruszka@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40696
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753160AbZDOJ2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 05:28:18 -0400
In-Reply-To: <20090415100937.4b08ce28@dhcp-lab-109.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stanislaw Gruszka <sgruszka@redhat.com>
Date: Wed, 15 Apr 2009 10:09:37 +0200

> Add LRO alignment initially committed in 621544eb8c3beaa859c75850f816dd9b056a00a3
> and removed in 0dcffac1a329be69bab0ac604bf7283737108e68 during conversion to
> multi-slice.
> 
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>

Applied, thanks.

Please, in the future, add the header string of the commit message
when referencing GIT commits.  When this patch is added to the -stable
kernel or similar the GIT commit ideas might be different and it
will be impossible for someone reading your commit message to find
the referenced commit using only the SHA ID.

I fixed that up for you this time.

Also, it would great to get this driver converted over to GRO,
such bugs like this one aren't even possible with GRO :-)
