From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] proportional share accept()
Date: Wed, 25 Feb 2004 10:12:25 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040225101225.496d02d0.davem@redhat.com>
References: <Pine.LNX.4.44.0402250818060.2878-100000@loopback.beaverton.ibm.com>
	<20040225092116.2081ddfb@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kashyapv@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040225092116.2081ddfb@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 25 Feb 2004 09:21:16 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Just a cursory question, but would it be possible to just use iptables
> to classify the packets and assign them to different IP addresses.
> The the application could manage the priorities by opening two different
> sockets (bound to different IP addresses) and do the scheduling there?

That's how I would attempt to implement this.  I really don't like this
idea of putting a pseudo-classifier in the accept queue logic, and an
ugly GLOBAL one at that, if anything it ought to be per-socket but even
that I don't like.
