From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH v3 1/6] net: pad skb data and shinfo as a whole rather
 than individually
Date: Wed, 1 Feb 2012 09:38:47 +0000
Message-ID: <1328089127.17444.9.camel@zakaz.uk.xensource.com>
References: <1327494389.24561.316.camel@zakaz.uk.xensource.com>
	 <1327494434-21566-1-git-send-email-ian.campbell@citrix.com>
	 <1327495879.2425.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1327496953.24561.323.camel@zakaz.uk.xensource.com>
	 <1327497157.2425.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1328020528.26983.396.camel@zakaz.uk.xensource.com>
	 <20120131145417.GA19990@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:24777 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753917Ab2BAJiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 04:38:50 -0500
In-Reply-To: <20120131145417.GA19990@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-01-31 at 14:54 +0000, Francois Romieu wrote:
> Ian Campbell <Ian.Campbell@citrix.com> :
> [...]
> > I'm using a single NIC transmitter, no delay, 1000000 clones of each skb
> > and I've tried 60 and 1500 byte packets. In the 60 byte case I see more
> > like 50k pps
> 
> At this stage 'tools/perf/perf top -G graph' sometimes helps me discover
> debug options that I had left enabled.

Thanks for the tip, I'll give it a look.

Ian.
