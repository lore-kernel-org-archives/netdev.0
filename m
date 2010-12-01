From: David Miller <davem@davemloft.net>
Subject: Re: multi bpf filter will impact performance?
Date: Wed, 01 Dec 2010 10:44:50 -0800 (PST)
Message-ID: <20101201.104450.183053379.davem@davemloft.net>
References: <18eaf7d286236427b1632b9af62be513@localhost>
	<20101201.101809.71122121.davem@davemloft.net>
	<1291227893.2856.1039.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hagen@jauu.net, xiaosuo@gmail.com, wirelesser@gmail.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50382
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752882Ab0LASoX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 13:44:23 -0500
In-Reply-To: <1291227893.2856.1039.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 01 Dec 2010 19:24:53 +0100

> A third work in progress (from my side) is to add a check in
> sk_chk_filter() to remove the memvalid we added lately to protect the
> LOAD M(K).

I understand your idea, but the static checkers are still going to
complain.  So better add a huge comment in sk_run_filter() explaining
why the checker's complaint should be ignored :-)
