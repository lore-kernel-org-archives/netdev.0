From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: jumbo frames and memory fragmentation
Date: Fri, 30 Jun 2006 11:53:36 -0600
Message-ID: <44A56520.5010703@nortel.com>
References: <E1FwIcw-00068x-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04e.nortel.com ([47.129.242.56]:50885 "EHLO
	zcars04e.nortel.com") by vger.kernel.org with ESMTP id S932931AbWF3Rxo
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 13:53:44 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1FwIcw-00068x-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

> Either upgrade your kernel or backport the page-splitting code in the
> current tree.  That's really the only sane solution for jumbo packets.

Looking at the page-splitting code, it says "82571 and greater support 
packet-split...".  We're running the 82546GB device.  Looks like it 
won't help me.

Chris
