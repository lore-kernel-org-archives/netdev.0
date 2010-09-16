From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] xmit_compl_seq: information to reclaim vmsplice
 buffers
Date: Wed, 15 Sep 2010 21:38:32 -0700 (PDT)
Message-ID: <20100915.213832.43031989.davem@davemloft.net>
References: <alpine.DEB.1.00.1009141318490.20088@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sridharr@google.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40239
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751713Ab0IPEiN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 00:38:13 -0400
In-Reply-To: <alpine.DEB.1.00.1009141318490.20088@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


And SIOCOUTQ doesn't work because?

It tells you how much of the current queued data hasn't
been sequentially ACK'd yet, from which you can derive
which buffers are still in-use.
