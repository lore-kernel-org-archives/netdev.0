From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: How to count tx and rx bytes?
Date: Mon, 15 Dec 2003 14:40:49 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031215144049.7acea87e.rddunlap@osdl.org>
References: <3FDE13AE.3050402@candelatech.com>
	<20031215141729.15387fc1.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031215141729.15387fc1.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 15 Dec 2003 14:17:29 -0800 "David S. Miller" <davem@redhat.com> wrote:

| On Mon, 15 Dec 2003 12:03:58 -0800
| Ben Greear <greearb@candelatech.com> wrote:
| 
| > Is there an agreed upon standard for exactly what ethernet drivers
| > should be counting for rx-bytes and tx-bytes?  For example, should the
| > counters include the 4-byte FCS?  Should they include the ethernet header?
| 
| Good question.
| 
| It should be that all drivers use what skb->len ends up with at
| rx/tx time.
| 
| However, it is often faster to just let the hardware keep track
| of these statistics (tg3 is one example of a chip that can do
| this).  And sometimes these mechanisms take the FCS or whatever
| into account and this as you note makes the numbers different.


RFC 1573:
RFC 2233:
RFC 1213:
all agree that on an "interface" the number of octets received (InOctets)
is:
 The total number of octets received on the interface, including
 framing characters.

so I read that as including MAC headers and FCS.  Without reading
these, I would have said include MAC headers but not FCS.

Similar for OutOctets.

--
~Randy
MOTD:  Always include version info.
