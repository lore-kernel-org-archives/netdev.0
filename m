From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: chunkmap size is too large
Date: Sun, 01 Feb 2009 01:14:27 -0800 (PST)
Message-ID: <20090201.011427.38305360.davem@davemloft.net>
References: <4983200B.2080707@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	kaber@netfilter.org
To: olivier.matz@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40666
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752218AbZBAJOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Feb 2009 04:14:31 -0500
In-Reply-To: <4983200B.2080707@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Olivier MATZ <olivier.matz@6wind.com>
Date: Fri, 30 Jan 2009 16:43:07 +0100

> I think that the chunkmap field in struct xt_sctp_info is
> too large: we have 256 chunk types and it's a bitfield,
> so the table should be 256 bits (8 uint32_t) instead
> of 64 uint32_t.
> 
> I updated the size of the table, and I did some cosmetic
> changes in SCTP_CHUNKMAP_* macros (use a mask instead of
> a modulo).
> 
>   netfilter/xt_sctp.h       |   30 ++++++++++++++++--------------
>   netfilter_ipv4/ipt_sctp.h |   30 ++++++++++++++++--------------
>   2 files changed, 32 insertions(+), 28 deletions(-)
> 
> Can someone have a look at it ? Please CC me for any replies
> as I'm not on the list.

Patrick, I assume you got this?
