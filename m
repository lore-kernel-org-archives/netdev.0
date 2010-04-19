From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Mon, 19 Apr 2010 14:19:47 -0700 (PDT)
Message-ID: <20100419.141947.129754682.davem@davemloft.net>
References: <20100419.130905.210660275.davem@davemloft.net>
	<20100419.132318.192086187.davem@davemloft.net>
	<1271709121.3845.94.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58431
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752063Ab0DSVTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 17:19:45 -0400
In-Reply-To: <1271709121.3845.94.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 19 Apr 2010 22:32:01 +0200

> Hmm, this was not a formal patch, just an information.
> 
> Problem is if hardware provides rxhash, will it be "consistent" too ?

Yes, it is an issue.  I am not aware of whether the Toeplitz
hash computed by cards is impervious to the order of the
input bits of not, probably it is.

I was thinking also about how we could compute rxhash in the
loopback driver :-)
