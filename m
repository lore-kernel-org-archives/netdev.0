From: David Miller <davem@davemloft.net>
Subject: Re: ip_queue_xmit() used illegally
Date: Fri, 06 May 2011 14:28:51 -0700 (PDT)
Message-ID: <20110506.142851.48495105.davem@davemloft.net>
References: <20110506.122656.189696988.davem@davemloft.net>
	<20110506.132129.59693228.davem@davemloft.net>
	<4DC463C7.5030407@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yjwei@cn.fujitsu.com, jchapman@katalix.com
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37790
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932718Ab1EFV3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2011 17:29:24 -0400
In-Reply-To: <4DC463C7.5030407@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vladislav.yasevich@hp.com>
Date: Fri, 06 May 2011 17:10:31 -0400

> I'll take a look at ->queue_xmit() to see if SCTP can convert to using that.

It already does via sctp_v4_queue_xmit() --> ip_queue_xmit().

I have a plan which I'm working on already, it will involve putting
a "struct flowi" into the sctp_transport.
