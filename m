From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH v2] net: filter: Just In Time compiler
Date: Wed, 20 Apr 2011 10:27:18 +0200
Message-ID: <dfdaf466cb9434e7825c861f78070a4d@localhost>
References: <1302797147.3248.32.camel@edumazet-laptop>
 <4DAE8E47.7040409@redhat.com> <1303286878.3186.17.camel@edumazet-laptop>
 <20110420.011454.226757908.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: <eric.dumazet@gmail.com>, <avi@redhat.com>,
	<netdev@vger.kernel.org>, <acme@infradead.org>,
	<bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:47526 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750768Ab1DTI1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 04:27:20 -0400
In-Reply-To: <20110420.011454.226757908.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 20 Apr 2011 01:14:54 -0700 (PDT), David Miller wrote:



I am fine with this patch too:



Acked-by: Hagen Paul Pfeifer <hagen@jauu.net>



Hopefully someone dig into the BPF optimizer in libpcap - cause there lie

the big optimization potential. Trivial filter rules like "host

192.168.1.1" cannot really be optimized - the unavoidable code path is the

"problem".



Hagen
