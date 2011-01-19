From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: user perfect name for Delayed SACK Timer option
Date: Tue, 18 Jan 2011 23:39:32 -0800 (PST)
Message-ID: <20110118.233932.91327830.davem@davemloft.net>
References: <4D3693CA.40508@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, yjwei@cn.fujitsu.com,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34278
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752400Ab1ASHi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 02:38:58 -0500
In-Reply-To: <4D3693CA.40508@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Wed, 19 Jan 2011 15:33:30 +0800

> The option name of Delayed SACK Timer should be SCTP_DELAYED_SACK,
> not SCTP_DELAYED_ACK.
> 
> Reference:
> 8.1.19.  Get or Set Delayed SACK Timer (SCTP_DELAYED_SACK)
> （http://tools.ietf.org/html/draft-ietf-tsvwg-sctpsocket-25)
> 
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>

You can't make this change, you'll break applications using the
existing definition.
