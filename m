From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH v2] tcp: TCP Small Queues
Date: Thu, 12 Jul 2012 09:34:19 +0200
Message-ID: <1342078459.3265.8244.camel@edumazet-glaptop>
References: <CAA93jw7ywd0auqN=k2J4fLOGYMLRH+agWr4P+_CisgvRtvgJUw@mail.gmail.com>
	<1340945457.29822.7.camel@edumazet-glaptop>
	<1341396687.2583.1757.camel@edumazet-glaptop>
	<20120709.000834.1182150057463599677.davem@davemloft.net>
	<1341845722.3265.3065.camel@edumazet-glaptop>
	<1341933215.3265.5476.camel@edumazet-glaptop>
	<1342019518.3265.8116.camel@edumazet-glaptop> <4FFDC985.6050805@hp.com>
	<1342050592.3265.8195.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nanditad@google.com, netdev@vger.kernel.org, mattmathis@google.com,
	codel@lists.bufferbloat.net, ncardwell@google.com,
	David Miller <davem@davemloft.net>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <1342050592.3265.8195.camel@edumazet-glaptop>
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

On Thu, 2012-07-12 at 01:49 +0200, Eric Dumazet wrote:

> The 10Gb receiver is a net-next kernel, but the 1Gb receiver is a 2.6.38
> ubuntu kernel. They probably have very different TCP behavior.


I tested TSQ on bnx2x and 10Gb links.

I get full rate even using 65536 bytes for
the /proc/sys/net/ipv4/tcp_limit_output_bytes tunable

OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.246.8.37 () port 0 AF_INET : histogram
Local       Remote      Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Recv Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
1606536     2097152     16384  20.00   9411.12    10^6bits/s  2.40  S      4.27   S      0.502   0.892   usec/KB  
