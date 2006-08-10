From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH 1/4] [NETLINK]: Handle NLM_F_ECHO in netlink_rcv_skb()
Date: Fri, 11 Aug 2006 00:32:53 +0400
Message-ID: <20060810203252.GA6414@ms2.inr.ac.ru>
References: <20060809204821.216122988@postel.suug.ch> <20060809205439.434010049@postel.suug.ch> <20060810155120.GA494@ms2.inr.ac.ru> <20060810190210.GH14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:33693 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1751591AbWHJUdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2006 16:33:24 -0400
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20060810190210.GH14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> What's wrong with listening to the notification for that purpose?

Nothing! NLM_F_ECHO _is_ listening for notifications without subscription
to multicast groups and need to figure out what messages are yours.
But beyond this NLM_F_ECHO is totally subset of this.
Which still makes much more sense then echoing of a know thing, does not it?

Alexey


