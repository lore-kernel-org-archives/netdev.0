From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND] [NET] fib_rules: Flush route cache after rule
 modifications
Date: Wed, 28 Mar 2007 12:40:49 -0700 (PDT)
Message-ID: <20070328.124049.55726295.davem@davemloft.net>
References: <20070328154903.GO521@postel.suug.ch>
	<20070328.112417.08322226.davem@davemloft.net>
	<20070328193436.GP521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@o2.pl, netdev@vger.kernel.org, muli@il.ibm.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54793
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752680AbXC1Tkt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 15:40:49 -0400
In-Reply-To: <20070328193436.GP521@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 28 Mar 2007 21:34:36 +0200

> So people can choose to immediately flush by setting it to 0. It
> would also be consistent to the flush after route changes, the same
> delay is used there.

That's a good point I hadn't considered.

Therefore, I think I'll apply your patch, considering that.
