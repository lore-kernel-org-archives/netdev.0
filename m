From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/3] git-net: sctp build fix (not for applying)
Date: Wed, 03 Oct 2007 16:45:42 -0700 (PDT)
Message-ID: <20071003.164542.107940171.davem@davemloft.net>
References: <200710022104.l92L4dvJ022234@imap1.linux-foundation.org>
	<47039E3F.9020305@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58557
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751035AbXJCXpn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 19:45:43 -0400
In-Reply-To: <47039E3F.9020305@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Wed, 03 Oct 2007 09:50:55 -0400

> akpm@linux-foundation.org wrote:
> > From: Andrew Morton <akpm@linux-foundation.org>
> > 
> > net/sctp/sm_statetable.c:551: error: 'sctp_sf_tabort_8_4_8' undeclared here (not in a function)
> > 
> 
> Andrew, is the a result of the merge of net-2.6.24 with net-2.6?  

Actually, it is a result of merging with Linus's tree since your SCTP
bits were there already, that's why Andrew hit this.

> That's the only way I see this happening.

Right.

I'll resolve this cleanly as I rebase net-2.6.24 today.
