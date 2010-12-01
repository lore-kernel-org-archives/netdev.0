From: David Miller <davem@davemloft.net>
Subject: Re: multi bpf filter will impact performance?
Date: Wed, 01 Dec 2010 10:24:02 -0800 (PST)
Message-ID: <20101201.102402.189695333.davem@davemloft.net>
References: <1291192967.2856.492.camel@edumazet-laptop>
	<18eaf7d286236427b1632b9af62be513@localhost>
	<20101201.101809.71122121.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, xiaosuo@gmail.com, wirelesser@gmail.com,
	netdev@vger.kernel.org
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45641
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751475Ab0LASXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 13:23:35 -0500
In-Reply-To: <20101201.101809.71122121.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 01 Dec 2010 10:18:09 -0800 (PST)

> If people work on the BPF optimizer and BPF JITs in parallel, we'll have
> both ready at the same time.  win++

BTW, the JIT is non-trivial work for us because of non-linear SKBs.
We'd need some kind of helper stub or similar, with a straight line
fast path for the linear case.
