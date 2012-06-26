From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [PATCH v2 net-next] tcp: avoid tx starvation by SYNACK packets
Date: Tue, 26 Jun 2012 09:27:10 +0200
Message-ID: <201206260927.11945.hans.schillstrom@ericsson.com>
References: <1340686296.10893.115.camel@edumazet-glaptop> <201206260734.33472.hans.schillstrom@ericsson.com> <20120626.001124.36486380031998542.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"subramanian.vijay@gmail.com" <subramanian.vijay@gmail.com>,
	"dave.taht@gmail.com" <dave.taht@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ncardwell@google.com" <ncardwell@google.com>,
	"therbert@google.com" <therbert@google.com>,
	"brouer@redhat.com" <brouer@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw7.ericsson.se ([193.180.251.48]:44337 "EHLO
	mailgw7.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757562Ab2FZH1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 03:27:14 -0400
In-Reply-To: <20120626.001124.36486380031998542.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 26 June 2012 09:11:24 David Miller wrote:
> From: Hans Schillstrom <hans.schillstrom@ericsson.com>
> Date: Tue, 26 Jun 2012 07:34:31 +0200
> 
> > The big cycle consumer during a syn attack is SHA sum right now, 
> > so from that perspective it's better to add aes crypto (by using AES-NI) 
> > to the syn cookies instead of SHA sum. Even if only newer x86_64 can use it.
> 
> I'm surprised that x86 lacks an SHA1 instruction, even shitty sparcs
> have one now.
> 
> SHA1 seems overkill for what the syncookie code is trying to do, could
> you give the following a try?
> 

Sure, I'll give it a try later today 

Thanks
