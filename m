From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v3 1/6] net: pad skb data and shinfo as a whole rather than individually
Date: Tue, 31 Jan 2012 15:54:17 +0100
Message-ID: <20120131145417.GA19990@electric-eye.fr.zoreil.com>
References: <1327494389.24561.316.camel@zakaz.uk.xensource.com> <1327494434-21566-1-git-send-email-ian.campbell@citrix.com> <1327495879.2425.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1327496953.24561.323.camel@zakaz.uk.xensource.com> <1327497157.2425.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1328020528.26983.396.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43058 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753152Ab2AaPFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 10:05:30 -0500
Content-Disposition: inline
In-Reply-To: <1328020528.26983.396.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ian Campbell <Ian.Campbell@citrix.com> :
[...]
> I'm using a single NIC transmitter, no delay, 1000000 clones of each skb
> and I've tried 60 and 1500 byte packets. In the 60 byte case I see more
> like 50k pps

At this stage 'tools/perf/perf top -G graph' sometimes helps me discover
debug options that I had left enabled.

-- 
Ueimor
