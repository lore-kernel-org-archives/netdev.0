From: David Miller <davem@davemloft.net>
Subject: Re: SWS for rcvbuf < MTU
Date: Fri, 02 Mar 2007 11:25:42 -0800 (PST)
Message-ID: <20070302.112542.18305896.davem@davemloft.net>
References: <200703021128.29208.alexandre.sidorenko@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexandre.sidorenko@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47052
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965187AbXCBTZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 14:25:43 -0500
In-Reply-To: <200703021128.29208.alexandre.sidorenko@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alex Sidorenko <alexandre.sidorenko@hp.com>
Date: Fri, 2 Mar 2007 11:28:28 -0500

> Customer has confirmed that this resolves the problem and decreases
> CPU usage by his custom application - even when there is no SWS.

There is rarely ever a reason to set explicit socket receive
buffer sizes, since the kernel dynamically sizes them based
upon how the connection is used.

Why do they set it so low?

It is just as easy to fix their performance bug by simply removing
SO_RCVBUF setting in the application.
