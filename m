From: CaT <cat@zip.com.au>
Subject: Re: 2.4.21+ - IPv6 over IPv4 tunneling b0rked
Date: Fri, 11 Jul 2003 01:58:02 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030710155802.GF1722@zip.com.au>
References: <20030710154302.GE1722@zip.com.au> <20030711.005542.04973601.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, pekkas@netcore.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20030711.005542.04973601.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jul 11, 2003 at 12:55:42AM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> > ip addr add 3ffe:8001:000c:ffff::37/127 dev sit1
> >  ip route add ::/0 via 3ffe:8001:000c:ffff::36 
> > RTNETLINK answers: Invalid argument
> 
> This is not bug, but rather misconfiguration;
> you cannot use prefix::, which is mandatory subnet routers 
> anycast address, as unicast address.

Ok. I'm a bit lost then. What should the line be then? To me the above
makes sense (and used to work), but then I'm not that experienced with
IPv6...

-- 
"How can I not love the Americans? They helped me with a flat tire the
other day," he said.
	- http://www.toledoblade.com/apps/pbcs.dll/artikkel?SearchID=73139162287496&Avis=TO&Dato=20030624&Kategori=NEWS28&Lopenr=106240111&Ref=AR
