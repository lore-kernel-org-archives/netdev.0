From: "David S. Miller" <davem@redhat.com>
Subject: Re: RFC/PATCH capture qdisc requeue event in stats
Date: Mon, 30 Aug 2004 16:00:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040830160052.548c4846.davem@redhat.com>
References: <1093799632.1073.410.camel@jzny.localdomain>
	<20040830144033.2265a6e6.davem@redhat.com>
	<1093904088.1043.12.camel@jzny.localdomain>
	<20040830154430.769d1d59.davem@redhat.com>
	<1093906592.1037.32.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1093906592.1037.32.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 30 Aug 2004 18:56:32 -0400
jamal <hadi@cyberus.ca> wrote:

> Sounds reasonable to me. Some of the BSDs do this to maintain old compat
> - just means keeping old struct around. Steve, agreeable to you? 
> 
> Change to both kernel and user space or just user space?

But this takes care of 'tc' only.  What about other programs
grabbing TC_STATS?  The whole world of netlink is not the
iproute2 tree.

Maybe instead we should create TC_STATS2?  That's a lot of
work just to add this one new statistic, I must say.
