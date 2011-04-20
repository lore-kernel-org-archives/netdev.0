From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 6/8] sctp: teach CACC algorithm about
 removed transports
Date: Tue, 19 Apr 2011 21:47:35 -0700 (PDT)
Message-ID: <20110419.214735.52170069.davem@davemloft.net>
References: <4DAD18AB.3040401@cn.fujitsu.com>
	<4DAD1A14.9060603@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54827
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751614Ab1DTEsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 00:48:10 -0400
In-Reply-To: <4DAD1A14.9060603@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Tue, 19 Apr 2011 13:13:56 +0800

> From: Vlad Yasevich <vladislav.yasevich@hp.com>
> 
> When we have have to remove a transport due to ASCONF, we move
> the data to a new active path.  This can trigger CACC algorithm
> to not mark that data as missing when SACKs arrive.  This is
> because the transport passed to the CACC algorithm is the one
> this data is sitting on, not the one it was sent on (that one
> may be gone).  So, by sending the original transport (even if
> it's NULL), we may start marking data as missing.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Applied.
