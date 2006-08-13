From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH 1/4] [NETLINK]: Handle NLM_F_ECHO in netlink_rcv_skb()
Date: Sun, 13 Aug 2006 17:45:23 +0400
Message-ID: <20060813134523.GA15671@ms2.inr.ac.ru>
References: <20060809204821.216122988@postel.suug.ch> <20060809205439.434010049@postel.suug.ch> <20060810155120.GA494@ms2.inr.ac.ru> <20060810190210.GH14627@postel.suug.ch> <20060810203252.GA6414@ms2.inr.ac.ru> <20060810211833.GK14627@postel.suug.ch> <20060811153549.GA16351@ms2.inr.ac.ru> <20060811214744.GO14627@postel.suug.ch> <20060812110331.GA31479@ms2.inr.ac.ru> <20060812111908.GP14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:42152 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1751169AbWHMNqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Aug 2006 09:46:08 -0400
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20060812111908.GP14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> So we do something like this:

Yes, exactly.

Actually, there was a function with similar functionality: rtnetlink_send().
net/sched/* used it, older net/ipv4/ still did this directly.

Alexey
