From: David Miller <davem@davemloft.net>
Subject: Re: net-next-2.6 status...
Date: Wed, 16 Mar 2011 11:17:36 -0700 (PDT)
Message-ID: <20110316.111736.48500809.davem@davemloft.net>
References: <20110316084022.GA2845@psychotron.brq.redhat.com>
	<20110316.104236.104065822.davem@davemloft.net>
	<1300299219.2811.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, netfilter-devel@vger.kernel.org,
	eric.dumazet@gmail.com, linville@tuxdriver.com, kaber@trash.net
To: bhutchings@solarflare.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1300299219.2811.7.camel@bwh-desktop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 16 Mar 2011 18:13:39 +0000

> Though, in this case, the priv_flags are not in any way visible to
> user-space, so it would be quite hard to find a use for them!

There are pieces of infrastructure, such as scripts that turn header
file visible macro values into values usable in other languages such
as perl, that do that wholesale for entire header files and therefore
expect these individual values to be there.

I'm not going to be the person who breaks such things.
