From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] net/netlink/af_netlink.c: possible cleanups
Date: Mon, 27 Dec 2004 19:08:16 -0800
Message-ID: <20041227190816.1d166ba2.davem@davemloft.net>
References: <20041215004604.GH23151@stusta.de>
	<1103119623.1077.71.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bunk@stusta.de, alan@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1103119623.1077.71.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 15 Dec 2004 09:07:03 -0500
jamal <hadi@cyberus.ca> wrote:

> I think this should be left alone for now; what we need to do is
> deprecate NETLINK_DEV incase someone is still using it.
> Else we could get rid of it totaly including what Adrian is deleting
> below. Any users of NETLINK_DEV? Maybe deleting the feature will get
> someone whining? ;->

While I agree we should probably just kill NETLINK_DEV now
and don't look back, I have applied Adrian's patch for
the time being.
