From: bert hubert <ahu@ds9a.nl>
Subject: Re: automatic keying works! Re: off by one error in 3des cbc keying
Date: Mon, 18 Nov 2002 21:22:29 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021118202229.GA22818@outpost.ds9a.nl>
References: <20021118195618.GA22603@outpost.ds9a.nl> <200211182004.XAA12908@sex.inr.ac.ru> <20021118.121047.99725598.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, gem@asplinux.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20021118.121047.99725598.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 18, 2002 at 12:10:47PM -0800, David S. Miller wrote:

>    Yes, their interaction is still... mmm... not polished.

I love the way you say this :-)

>    Build both xfrm_user and af_key as modules and load only one for now.
>    
> You added xfrm netlink support to libipsec?
> 
> If not, the only thing which should get in the way is that there
> are two key managers registered but that should "just work" :)

It does not, Alexey is right. Without CONFIG_XFRM_USER, racoon works again.
Would you perhaps want to explain what CONFIG_XFRM_USER is going to be like?
Netlink instead of PFKEY, but other notable things?

Regards,

bert

-- 
http://www.PowerDNS.com          Versatile DNS Software & Services
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
