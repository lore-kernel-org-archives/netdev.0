From: David Miller <davem@davemloft.net>
Subject: Re: VIA velocity skb leak.
Date: Wed, 11 Mar 2009 21:17:06 -0700 (PDT)
Message-ID: <20090311.211706.68465072.davem@davemloft.net>
References: <20090312041352.GA6035@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60039
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752094AbZCLERU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 00:17:20 -0400
In-Reply-To: <20090312041352.GA6035@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


velocity_xmit() needs to set 'pktlen = skb->len;' after,
not before, the skb_padto() call.
