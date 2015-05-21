From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] tcp: add tcpi_segs_in and tcpi_segs_out to tcp_info
Date: Wed, 20 May 2015 17:06:37 -0700
Message-ID: <555D218D.50509@hp.com>
References: <1430260098-14127-1-git-send-email-edumazet@google.com> <20150512130855.GA29412@localhost.localdomain> <1431462713.566.95.camel@edumazet-glaptop2.roam.corp.google.com> <1432164941.4060.57.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Craig Gallek <cgallek@google.com>, Martin Lau <kafai@fb.com>,
	Chris Rapier <rapier@psc.edu>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t5008.houston.hp.com ([15.240.92.66]:49221 "EHLO
	g9t5008.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751962AbbEUAGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 20:06:48 -0400
In-Reply-To: <1432164941.4060.57.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/20/2015 04:35 PM, Eric Dumazet wrote:
> From: Marcelo Ricardo Leitner <mleitner@redhat.com>
>
> This patch tracks the total number of inbound and outbound segments on a
> TCP socket. One may use this number to have an idea on connection
> quality when compared against the retransmissions.
>
> RFC4898 named these : tcpEStatsPerfSegsIn and tcpEStatsPerfSegsOut
>
> These are a 32bit field each and can be fetched both from TCP_INFO
> getsockopt() if one has a handle on a TCP socket, or from inet_diag
> netlink facility (iproute2/ss patch will follow)

I suppose it is far-fetched, but is it a concern that at 100 Gbit/s and 
1500 byte MTU the 32 bit segment counter would wrap in something like 
500 seconds and change?

rick jones
