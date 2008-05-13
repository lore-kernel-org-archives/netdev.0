From: David Miller <davem@davemloft.net>
Subject: Re: autotuning of send buffer size of a socket
Date: Mon, 12 May 2008 17:51:53 -0700 (PDT)
Message-ID: <20080512.175153.155979702.davem@davemloft.net>
References: <4a4634330805121200m739e67bdife66c3ad81af1ceb@mail.gmail.com>
	<1210639647.2753.10.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shirishpargaonkar@gmail.com, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35014
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755980AbYEMAwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 20:52:00 -0400
In-Reply-To: <1210639647.2753.10.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Mon, 12 May 2008 17:47:27 -0700

> Also, the comments for tcp_new_space() says that sndbuf expansion does
> not work well with largesends. What is the size of your sends?

That's talking about TSO.  It's an obsolete comment that is no longer
true and thus should be removed.
