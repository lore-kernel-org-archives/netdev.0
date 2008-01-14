From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 1/4][NETNS][RAW]: Make ipv[46] raw sockets
 lookup namespaces aware.
Date: Mon, 14 Jan 2008 05:36:58 -0800 (PST)
Message-ID: <20080114.053658.60090958.davem@davemloft.net>
References: <478B5DBB.6020603@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48266
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750695AbYANNhB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 08:37:01 -0500
In-Reply-To: <478B5DBB.6020603@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 14 Jan 2008 16:03:55 +0300

> This requires just to pass the appropriate struct net pointer 
> into __raw_v[46]_lookup and skip sockets that do not belong
> to a needed namespace.
> 
> The proper net is get from skb->dev in all the cases.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
