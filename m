From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] AF_VMCHANNEL address family for guest<->host
 communication.
Date: Mon, 15 Dec 2008 00:27:28 -0800 (PST)
Message-ID: <20081215.002728.112665573.davem@davemloft.net>
References: <20081214115054.4066.14557.stgit@dhcp-1-237.tlv.redhat.com>
	<20081214.224436.55256593.davem@davemloft.net>
	<20081215074819.GV5555@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	kvm@vger.kernel.org
To: gleb@redhat.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20081215074819.GV5555@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gleb Natapov <gleb@redhat.com>
Date: Mon, 15 Dec 2008 09:48:19 +0200

> On Sun, Dec 14, 2008 at 10:44:36PM -0800, David Miller wrote:
> > You guys really need to rethink this.  Either a stream protocol is a
> > workable solution to your problem, or it isn't.
>
> Stream protocol is workable solution for us, but we need it out of band
> in regard to networking and as much zero config as possible. If we will
> use networking how can it be done without additional configuration (and
> reconfiguration can be required after migration BTW)

You miss the whole point and you also missed the part where I said
(and the one part of my comments you conveniently did NOT quote):

--------------------
And don't bring up any "virtualization is special because..."
arguments into your reply because virtualization has nothing to do
with my objections stated above.
--------------------

What part of that do you not understand?  Don't give me this
junk about zero config, it's not a plausible argument against
anything I said.

You want to impose a new burdon onto the kernel in the form of a whole
new socket layer.  When existing ones can solve any communications
problem.

Performance is not a good argument because we have (repeatedly) made
TCP/IP go fast in just about any environment.

If you have a configuration problem, you can solve it in userspace in
a number of different ways.  Building on top of things we have and the
user need not know anything about that.

I would even be OK with features such as "permanent" links or special
attributes for devices or IP addresses that by default prevent
tampering and filtering by things like netfilter.

But not this new thing that duplicates existing functionality, no way.
