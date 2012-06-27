From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [PATCH v2 net-next] tcp: avoid tx starvation by SYNACK packets
Date: Wed, 27 Jun 2012 10:30:57 +0200
Message-ID: <201206271030.58701.hans.schillstrom@ericsson.com>
References: <201206260734.33472.hans.schillstrom@ericsson.com> <201206270723.11615.hans.schillstrom@ericsson.com> <20120627.012204.1603944185909940692.davem@davemloft.net>
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
Received: from mailgw1.ericsson.se ([193.180.251.45]:44974 "EHLO
	mailgw1.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080Ab2F0IbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 04:31:01 -0400
In-Reply-To: <20120627.012204.1603944185909940692.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 27 June 2012 10:22:04 David Miller wrote:
> From: Hans Schillstrom <hans.schillstrom@ericsson.com>
> Date: Wed, 27 Jun 2012 07:23:03 +0200
> 
> > On Tuesday 26 June 2012 19:02:36 Eric Dumazet wrote:
> >> With David patch using jhash instead of SHA, I reach ~315.000 SYN per
> >> second.
> > 
> > I have similar results from ~170k to ~199k synack/sec.
> 
> Eric and Hans, I'm going to add Tested-by: tags for both of you
> when I commit this patch if you don't mind. :-)
> 

No problems, go ahead
