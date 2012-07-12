From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH v2] tcp: TCP Small Queues
Date: Thu, 12 Jul 2012 00:37:00 -0700 (PDT)
Message-ID: <20120712.003700.49235222504944712.davem@davemloft.net>
References: <4FFDC985.6050805@hp.com>
	<1342050592.3265.8195.camel@edumazet-glaptop>
	<1342078459.3265.8244.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nanditad@google.com, netdev@vger.kernel.org, mattmathis@google.com,
	codel@lists.bufferbloat.net, ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <1342078459.3265.8244.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Sender: codel-bounces@lists.bufferbloat.net
Errors-To: codel-bounces@lists.bufferbloat.net
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 12 Jul 2012 09:34:19 +0200

> On Thu, 2012-07-12 at 01:49 +0200, Eric Dumazet wrote:
> 
>> The 10Gb receiver is a net-next kernel, but the 1Gb receiver is a 2.6.38
>> ubuntu kernel. They probably have very different TCP behavior.
> 
> 
> I tested TSQ on bnx2x and 10Gb links.
> 
> I get full rate even using 65536 bytes for
> the /proc/sys/net/ipv4/tcp_limit_output_bytes tunable

Great work Eric.
