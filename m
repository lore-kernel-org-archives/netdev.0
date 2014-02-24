From: David Miller <davem@davemloft.net>
Subject: Re: [RFC v2 2/4] net: enables interface option to skip IP
Date: Mon, 24 Feb 2014 18:04:26 -0500 (EST)
Message-ID: <20140224.180426.411052665068255886.davem@davemloft.net>
References: <1392857777.22693.14.camel@dcbw.local>
	<CAB=NE6Xvqcdje5OSxjzTRa3wv-vZHr+MJHY86ZCfFXU2Lpzi8Q@mail.gmail.com>
	<1393266120.8041.19.camel@dcbw.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcgrof@do-not-panic.com, zoltan.kiss@citrix.com,
	netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: dcbw@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393266120.8041.19.camel@dcbw.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Williams <dcbw@redhat.com>
Date: Mon, 24 Feb 2014 12:22:00 -0600

> In the future I expect more people will want to disable IPv4 as
> they move to IPv6.

I definitely don't.

I've been lightly following this conversation and I have to say
a few things.

disable_ipv6 was added because people wanted to make sure their
machines didn't generate any ipv6 traffic because "ipv6 is not
mature", "we don't have our firewalls configured to handle that
kind of traffic" etc.

None of these things apply to ipv4.

And if you think people will go to ipv6 only, you are dreaming.

Name a provider of a major web sitewho will go to strictly only
providing an ipv6 facing site?

Only an idiot who wanted to lose significiant nunbers of page views
and traffic would do that, so ipv4 based connectivity will be
universally necessary forever.

I think disable_ipv4 is absolutely a non-starter.
