From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH]  802.1Q VLAN
Date: Fri, 29 Oct 2004 02:38:08 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3acu6xssv.fsf@defiant.pm.waw.pl>
References: <41797696.9070905@candelatech.com>
	<20041022214611.GA4948@electric-eye.fr.zoreil.com>
	<41798506.1030909@candelatech.com> <417D675F.3000909@candelatech.com>
	<4181838B.6040002@tpack.net> <41818D99.9020300@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tommy Christensen <tommy.christensen@tpack.net>,
        "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>,
        "Linux 802.1Q VLAN" <vlan@candelatech.com>,
        Francois Romieu <romieu@fr.zoreil.com>,
        "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <41818D99.9020300@candelatech.com> (Ben Greear's message of
 "Thu, 28 Oct 2004 17:23:53 -0700")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ben Greear <greearb@candelatech.com> writes:

> Right... it would probably be an O(N) thing to wake the queues for all virtual
> devices on a physical device, and we certainly don't want to do that
> often.  Maybe if you only tried to wake the blocked queues (ie, kept a list
> of just blocked queues), then that would be less painful on average,
> but the worst-case is still bad.

Not sure if we need multiple queues. I think one queue for one physical
device (a queue shared by all logical subdevices) would be enough
in this case.

Not sure how to do it, either. The semantics should be changed perhaps.


The same issue with Frame Relay logical devices.
-- 
Krzysztof Halasa
