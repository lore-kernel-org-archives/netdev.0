From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] netfilter: use per-CPU r**ursive lock {XV}
Date: Tue, 28 Apr 2009 09:42:09 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0904280936220.21875@fbirervta.pbzchgretzou.qr>
References: <20090423210938.1501507b@nehalam> <49F146FF.5050200@cosmosbay.com> <20090424091839.6e13ebec@nehalam> <49F22465.80305@gmail.com> <20090425133052.4cb711f5@nehalam> <49F4A6E3.7080102@cosmosbay.com> <20090426185646.GB29238@Krystal>
 <20090426145746.1184aeba@nehalam> <1240854297.7620.65.camel@twins> <20090427113010.5e3f1700@nehalam> <20090427185423.GC23862@elte.hu> <20090427120658.35a858bb@nehalam> <alpine.LFD.2.00.0904271219570.22156@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	Evgeniy Polyakov <zbr@ioremap.net>, kaber@trash.net,
	jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com, r000n@r000n.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, benh@kernel.crashing.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:39220 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760653AbZD1HmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 03:42:10 -0400
In-Reply-To: <alpine.LFD.2.00.0904271219570.22156@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Monday 2009-04-27 21:46, Linus Torvalds wrote:

>Clue bat #3 [sic #4]:
>
> - if you do not understand the difference between these two things, don't 
>   then try to claim that somebody _else_ who does understand it is 
>   "deluding himself".
>
>   Analogy time: Ethernet and a modem line can both get you on the
>   internet. Now, let's say that Mr Peter Paste-Eater has heard of 
>   ethernet, and knows you can get on the internet with an ethernet 
>   connection, but he happens to use a modem line to do it.
>
>   Now, Peter Paste-Eater talks to you, and tells you he is connecting to 
>   the internet with ethernet, and proudly shows you his serial line and 
>   modem, and tells you how he uses ethernet to get onto the internet. You 
>   correct him, and tell him it's not ethernet.  He argues for several 
>   days about how he gets on the internet, and that it must thus be 
>   ethernet, and that you're obviously just "deluding yourself".
>
>Now, can you see why people react badly to you talking about "recursive 
>locks"? You're acting like Peter Paste-Eater calling his serial line 
>ethernet.

It could be worse. He could be running Ethernet over serial, e.g. L2TP.
Or his serial line is a TP cable with RJ45 plugs - consumers like
to call that Ethernet (cable) too.
