From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: 2.4.21+ - IPv6 over IPv4 tunneling b0rked
Date: Sun, 13 Jul 2003 19:23:05 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307131922411.23508-100000@netcore.fi>
References: <berrfo$mo3$1@main.gmane.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Anand Kumria <wildfire@progsoc.org>
In-Reply-To: <berrfo$mo3$1@main.gmane.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

See 
http://www.ietf.org/internet-drafts/draft-savola-ipv6-127-prefixlen-04.txt 
it should answer your questions.

On Mon, 14 Jul 2003, Anand Kumria wrote:
> On Fri, 11 Jul 2003 02:08:20 +1000, Pekka Savola wrote:
> 
> > On Fri, 11 Jul 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明
> > wrote:
> >> In article <20030710154302.GE1722@zip.com.au> (at Fri, 11 Jul 2003
> >> 01:43:03 +1000), CaT <cat@zip.com.au> says:
> >> 
> >> > With 2.4.21-pre2 I can get a nice tunnel going over my ppp connection
> >> > and as such get ipv6 connectivity. I think went to 2.4.21 and then to
> >> > 2.4.22-pre4 and bringing up the tunnel fails as follows:
> >> :
> >> > ip addr add 3ffe:8001:000c:ffff::37/127 dev sit1
> >> >  ip route add ::/0 via 3ffe:8001:000c:ffff::36
> >> > RTNETLINK answers: Invalid argument
> >> 
> >> This is not bug, but rather misconfiguration; you cannot use prefix::,
> >> which is mandatory subnet routers anycast address, as unicast address.
> 
> I'm the other end of this link, so I'm wondering how this is a
> misconfiguration. RFC3513 2.6.1 suggests to me that
> 3ffe:8001:c:ffff::36/127 is the router address (my end) and the other
> side should be 3ffe:8001:c:ffff::37/127.
> 
> > While technically correct, I'm still not sure if this is (pragmatically)
> > the correct approach.  It's OK to set a default route to go to the
> > subnet routers anycast address (so, setting a route to prefix:: should
> > not give you EINVAL).
> > 
> 
> Both Yoshifuji and yourself suggested that /127 isn't the way to go and
> that this is something v6ops ought to take up. I had a quick look at the
> v6ops IETF group and nothing struck me.
> 
> What would you recommend I look at to see why /127 is a bad idea or /64
> is a better idea than /127?
> 
> Thanks,
> Anand
> 
> 

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
