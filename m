From: "David S. Miller" <davem@davemloft.net>
Subject: Re: generic 802.11 stack
Date: Fri, 1 Oct 2004 17:11:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041001171158.489e3cf1.davem@davemloft.net>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua>
	<200410011630.59465.vkondra@mail.ru>
	<20041001155310.515ee09e.davem@davemloft.net>
	<200410020125.40669.vkondra@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, mcgrof@studorgs.rutgers.edu,
        acx100-devel@lists.sourceforge.net, prism54-devel@prism54.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Vladimir Kondratiev <vkondra@mail.ru>
In-Reply-To: <200410020125.40669.vkondra@mail.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2 Oct 2004 01:25:32 +0200
Vladimir Kondratiev <vkondra@mail.ru> wrote:

> DS> Next:
> DS>
> DS> +    dev->mtu                = 2304;
> DS> +    dev->type               = ARPHRD_IEEE80211;
> DS>
> DS> Is this really the correct default MTU for wireless devices?
> 
> Yes, 802.11e (QoS) defines this value.

All existing wireless drivers use the standard ethernet MTU.
I really think it is supposed to be 1500.

That's why I left it at ether_setup()'s setting.

Upper layers really want to see a 1500 byte standard ethernet
MTU by default.  It's OK to let people set this higher via
netdev->change_mtu() configuration calls, but by default it
should be something that makes sense for most networks and
that is 1500.

Yes, btw, your tabs are all screwed up.  Please configure
your editor to use real tab characters.  Your's is using
spaces and using a tab-stop of 4 when it should be 8.
