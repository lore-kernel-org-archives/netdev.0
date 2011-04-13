From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: fix oops while removed transport still using as
 retran path
Date: Tue, 12 Apr 2011 19:34:06 -0700 (PDT)
Message-ID: <20110412.193406.112617933.davem@davemloft.net>
References: <4DA4FA70.50506@cn.fujitsu.com>
	<4DA4FACE.5060706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35885
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754917Ab1DMCel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 22:34:41 -0400
In-Reply-To: <4DA4FACE.5060706@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Wed, 13 Apr 2011 09:22:22 +0800

> Since we can not update retran path to unconfirmed transports,
> when we remove a peer, the retran path may not be update if the
> other transports are all unconfirmed, and we will still using
> the removed transport as the retran path. This may cause panic
> if retrasnmit happen.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Applied.
