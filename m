From: bert hubert <ahu@ds9a.nl>
Subject: Re: automatic keying works! Re: off by one error in 3des cbc keying
Date: Mon, 18 Nov 2002 20:56:19 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021118195618.GA22603@outpost.ds9a.nl>
References: <20021113220311.GA29358@outpost.ds9a.nl> <200211132235.BAA13386@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, gem@asplinux.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200211132235.BAA13386@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Nov 14, 2002 at 01:35:39AM +0300, kuznet@ms2.inr.ac.ru wrote:
> > I now see a proper soft expire, new SAs being setup, old SAs in state 'dying',
> > and traffic flowing nicely. Even with soft expire and no traffic, I see a
> > new SA being negotiated.
> 
> Wait for a while and you will see message sort of:
> 
> Nov 13 20:48:59 mops  [291/0/0] racoon: INFO: isakmp.c:1521:isakmp_ph1expire():
> ISAKMP-SA expired 192.168.1.202[500]-192.168.1.106[500] spi:c9549e2b4f33f8a3:655bf176d4531765

Did IPSEC die in 2.5.48? I can't get automatic keying to work, it only says
this once every two minutes:

2002-11-18 20:54:15: DEBUG: pfkey.c:191:pfkey_handler(): get pfkey EXPIRE
message
2002-11-18 20:54:15: INFO: pfkey.c:1364:pk_recvexpire(): IPsec-SA expired:
ESP/Transport 10.0.0.216->10.0.0.11 
2002-11-18 20:54:15: DEBUG: pfkey.c:1376:pk_recvexpire(): no such a SA
found: ESP/Transport 10.0.0.216->10.0.0.11 

I did turn on CONFIG_XFRM_USER, does it conflict with PF_KEY?

Regards,

bert

-- 
http://www.PowerDNS.com          Versatile DNS Software & Services
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
