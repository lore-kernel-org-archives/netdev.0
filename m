From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [Ipsec-tools-devel] ipv4/ipv6 forwarding check
Date: Fri, 29 Oct 2004 00:04:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029000447.4e7b68e3.davem@davemloft.net>
References: <200410300506.i9U56Yse005815@faith.austin.ibm.com>
	<4181EBC3.3020507@gmc.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: latten@austin.ibm.com, ipsec-tools-devel@lists.sourceforge.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Aidas Kasparas <a.kasparas@gmc.lt>
In-Reply-To: <4181EBC3.3020507@gmc.lt>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 29 Oct 2004 10:05:39 +0300
Aidas Kasparas <a.kasparas@gmc.lt> wrote:

> 	4) extend setkey's syntax to make explicit forward policy management 
> possible and write docs for all the admins to change policies.

This is what we're advocating to happen.

There are reasons why people would want seperate INPUT, OUTPUT,
and FORWARD policies.  So we're not taking that capability out
of the kernel.  And by "auto-magically" making this happen
transparently you are taking the capability away, which is why
this idea won't fly either.

For the record, the freeswan tools handle all of this stuff
just fine.
