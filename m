From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [PATCH]  802.1Q VLAN
Date: Sat, 30 Oct 2004 02:31:02 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4182E0C6.6090205@tpack.net>
References: <41797696.9070905@candelatech.com>	 <20041022214611.GA4948@electric-eye.fr.zoreil.com>	 <41798506.1030909@candelatech.com> <417D675F.3000909@candelatech.com>	 <4181838B.6040002@tpack.net>  <41818D99.9020300@candelatech.com> <1099038566.1813.99.camel@cyan.cph.tpack.net> <418281C1.9080707@candelatech.com> <4182D44E.7070507@tpack.net> <4182DABE.7000502@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>,
        "Linux 802.1Q VLAN" <vlan@candelatech.com>,
        Francois Romieu <romieu@fr.zoreil.com>,
        "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <4182DABE.7000502@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> Can't you also add a queue to a VLAN device?

Sure you can. This is the best solution, if you have a way of
waking up the queue.

>> Nice. This idea is definitely worth persuing. However, ideally we
>> would want to be notified when the *qdisc* queue opens up - this
>> is our "tx ring buffer".
> 
> 
> Maybe the qdisc could automatically flush what it could to lower
> level devices/queues whenever it was asked to enqueue a packet?
> This way, waking the writers could automatically wake the various
> queues under the writers.
> 
> That could be happening already, and might explain why my pktgen hacks
> work.

Yes, this is what qdisc does. It just isn't good enough to have to
wait for the next packet, IMO.


-Tommy
