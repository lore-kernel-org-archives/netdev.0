From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter: don't need to initialize instance_table
Date: Thu, 09 Dec 2010 12:05:43 -0800 (PST)
Message-ID: <20101209.120543.112596810.davem@davemloft.net>
References: <1291889421-10794-1-git-send-email-xiaosuo@gmail.com>
	<alpine.LNX.2.01.1012091501270.21049@obet.zrqbmnf.qr>
	<AANLkTin6u9ZkSNAoxR7az5yBW-WM0RebPcCrOMOYgFrP@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jengelh@medozas.de, kaber@trash.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47956
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757013Ab0LIUFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 15:05:15 -0500
In-Reply-To: <AANLkTin6u9ZkSNAoxR7az5yBW-WM0RebPcCrOMOYgFrP@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Thu, 9 Dec 2010 22:27:24 +0800

> On Thu, Dec 9, 2010 at 10:03 PM, Jan Engelhardt <jengelh@medozas.de> wrote:
>>
>> This is here for correctness and documentation. If the hlist
>> implementation changed, one would have a hard time figuring out the
>> callsites which then need to add the initialization back.
>>
> 
> I am quite sure there are other users rely on this assumption. So who
> wants to change the macro INIT_HLIST_HEAD() has to review all the
> code. It is a huge task, but can't be avoided.

Wrong.  Adding debugging facilities to the hlist head would just
require changing this macro.

That is, unless we apply patches like your's, which we won't.
