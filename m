From: Ben Greear <greearb@candelatech.com>
Subject: Re: Change proxy_arp to respond only for valid neighbours
Date: Mon, 09 Feb 2004 13:39:51 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4027FE27.9020102@candelatech.com>
References: <Pine.LNX.4.58.0402082234110.6268@u.domain.uli> <20040209121926.6f016ebf.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Julian Anastasov <ja@ssi.bg>, netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040209121926.6f016ebf.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Sun, 8 Feb 2004 22:44:05 +0200 (EET)
> Julian Anastasov <ja@ssi.bg> wrote:
> 
> 
>>- the 'skb->pkt_type == PACKET_HOST' check has no semantic anymore,
>>the requestor should have same information no matter the packet
>>type. In all cases we add response delay for all requests, broadcast
>>or unicast, to help other authoritative hosts to reply before us.
> 
> 
> Do we really want to reply to all the garbage tcpdump causes us
> to capture?
> 
> That is what the pkt_type is dealing with.  If we're in promiscuous
> mode, we'll hear ARP requests meant not for any of our devices, we
> should not proxy for them right?

Arp requests are always broadcasts, so promisc changes nothing,
right?


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
