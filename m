From: bert hubert <ahu@ds9a.nl>
Subject: Re: [PATCH] fix tcp_default_win_scale.
Date: Wed, 7 Jul 2004 21:38:02 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040707193802.GA8117@outpost.ds9a.nl>
References: <20040701140406.62dfbc2a.davem@redhat.com> <20040702013225.GA24707@conectiva.com.br> <20040706093503.GA8147@outpost.ds9a.nl> <20040706114741.1bf98bbe@dell_ss3.pdx.osdl.net> <20040706194034.GA11021@mail.shareable.org> <20040706131235.10b5afa8.davem@redhat.com> <20040706224453.GA6694@outpost.ds9a.nl> <20040706154907.422a6b73.davem@redhat.com> <20040707110653.7c49bef1@dell_ss3.pdx.osdl.net> <20040707193125.GA17266@mail.shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
	"David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Jamie Lokier <jamie@shareable.org>
Content-Disposition: inline
In-Reply-To: <20040707193125.GA17266@mail.shareable.org>
List-Id: netdev.vger.kernel.org

On Wed, Jul 07, 2004 at 08:31:25PM +0100, Jamie Lokier wrote:

> So why do we set a larger window scale than necessary?
> Is it to support (a)?

It might be useful to shake out the bugs of the internet - so far I have
indications that at least on residential ADSL router is responsible, it
removes wscale when doing TCP portforwarding.

If and when we decide to do larger rmem than now, we might have a better
chance.

Regards,

bert

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
