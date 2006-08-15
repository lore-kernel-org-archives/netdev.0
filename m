From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [RFC 5/7] neighbour: convert lookup to sequence lock
Date: Tue, 15 Aug 2006 04:42:58 +0400
Message-ID: <20060815004258.GA10090@ms2.inr.ac.ru>
References: <20060814212004.606140865@localhost.localdomain> <20060814212143.845202090@localhost.localdomain> <20060814222220.GQ14627@postel.suug.ch> <20060814153743.0ab60955@localhost.localdomain> <20060814231718.GS14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:5515 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S965030AbWHOAnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 20:43:16 -0400
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20060814231718.GS14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> That wouldn't work if hard_header() ever expands the head. Fortunately
> hard_header() returns the length added even in case of an error so we
> can undo the absolute value returned.

Yes.

Or probably it is safer to undo to skb->nh. Even if hard_header
expands skb, skb->nh still remains valid.

Alexey
