From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 13/13] [RFC] [IPV6] Fix source prefix routing problems
 when source address undefined.
Date: Wed, 18 Oct 2006 01:49:59 +0900 (JST)
Message-ID: <20061018.014959.18582506.yoshfuji@linux-ipv6.org>
References: <20061017113511.GN12964@postel.suug.ch>
	<20061017.211730.51920084.yoshfuji@linux-ipv6.org>
	<20061017123415.GO12964@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vnuorval@tcs.hut.fi, davem@davemloft.net, kim.nordlund@nokia.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:49677 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1751318AbWJQQr0
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 12:47:26 -0400
To: tgraf@suug.ch
In-Reply-To: <20061017123415.GO12964@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20061017123415.GO12964@postel.suug.ch> (at Tue, 17 Oct 2006 14:34:15 +0200), Thomas Graf <tgraf@suug.ch> says:

> Right, that works as well but duplicating the rule for every
> interface is not very practical.

Though I think it is, but we could have "non-local" flag or such.

> Anyways, the point is that the proposed change to modify the
> source prefix matching logic is not acceptable and other way
> has to be found.

I still do not agree.

The "reject" case that you told me can also be solved using netfilter.
On the other side,  the source address selection can not be solved in
other way.  The stack is broken without the proposed patch.

--yoshfuji
