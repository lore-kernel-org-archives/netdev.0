From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET : Adding SO_TIMESTAMPNS / SCM_TIMESTAMPNS support
Date: Fri, 09 Mar 2007 14:17:24 -0800 (PST)
Message-ID: <20070309.141724.112850583.davem@davemloft.net>
References: <200703021538.41284.dada1@cosmosbay.com>
	<200703081517.57539.dada1@cosmosbay.com>
	<200703091939.42656.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arch@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43400
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933409AbXCIWRZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 17:17:25 -0500
In-Reply-To: <200703091939.42656.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 9 Mar 2007 19:39:42 +0100

> [PATCH] NET : Adding SO_TIMESTAMPNS / SCM_TIMESTAMPNS support
> 
> Now that network timestamps use ktime_t infrastructure, we can add a new 
> SOL_SOCKET sockopt  SO_TIMESTAMPNS.
> 
> This command is similar to SO_TIMESTAMP, but permits transmission of 
> a 'timespec struct' instead of a 'timeval struct' control message. 
> (nanosecond resolution instead of microsecond)
> 
> Control message is labelled SCM_TIMESTAMPNS instead of SCM_TIMESTAMP
> 
> A socket cannot mix SO_TIMESTAMP and SO_TIMESTAMPNS : the two modes are 
> mutually exclusive.
> 
> sock_recv_timestamp() became too big to be fully inlined so I added a 
> __sock_recv_timestamp() helper function.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> CC: linux-arch@vger.kernel.org
> 

Applied, thanks for following up on all of this nanosecond
timestamp work.
