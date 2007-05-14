From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [patch 04/13] ppp_generic: fix lockdep warning
Date: Mon, 14 May 2007 12:09:07 +0200
Message-ID: <20070514100907.GA2780@ff.dom.local>
References: <20070514060700.GA1000@ff.dom.local> <20070513.233937.99203647.davem@davemloft.net> <20070514072845.GA2081@ff.dom.local> <20070514.021831.68041288.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, jeff@garzik.org, netdev@vger.kernel.org,
	jura@netams.com, paulus@samba.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:49407 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1760095AbXENKCh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2007 06:02:37 -0400
Content-Disposition: inline
In-Reply-To: <20070514.021831.68041288.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 14, 2007 at 02:18:31AM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@o2.pl>
> Date: Mon, 14 May 2007 09:28:45 +0200
> 
> > Yes, this is very good idea, and I wonder, why you didn't try
> > this yourself (after my "ignore").
> 
> Because you are a skilled programmer and you might find some
> flaw in my suggestion :-)
> 

Yes, here are some flaws:

if (Dave_M_was_ignored)
	goto not_skilled_programmer;

if (Jarek_P_finds_some_flow)
	goto message_sent;
else
	goto message_sent; /* probably the same */

Cheers,
Jarek P.
