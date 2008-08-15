From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
Date: Fri, 15 Aug 2008 10:06:39 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808150939270.23522@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0808081256560.4551@wrl-59.cs.helsinki.fi>
 <20080811.144421.234396007.davem@davemloft.net> <200808120946.19459.thomas.jarosch@intra2net.com>
 <20080812.011822.155249871.davem@davemloft.net> <20080812144309.7d62fd86@tux>
 <Pine.LNX.4.64.0808122044450.16105@wrl-59.cs.helsinki.fi> <20080813145310.0c1e534c@tux>
 <Pine.LNX.4.64.0808132108480.18807@wrl-59.cs.helsinki.fi> <20080815013407.4a594288@tux>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1842071017-1218783999=:23522"
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>, sr@securenet.de,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "=?ISO-8859-1?Q?D=E2niel?= Fraga" <fragabr@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080815013407.4a594288@tux>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1842071017-1218783999=:23522
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Fri, 15 Aug 2008, Dâniel Fraga wrote:

> On Wed, 13 Aug 2008 21:34:10 +0300 (EEST)
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> 
> > Ok, thanks for your efforts... These are often hard to reproduce because
> > some not that likely pattern needs to happen and such things is often not
> > easily controllable (if it is at all possible to influence the 
> > likelyhoods).
> 
> 	Hi Ilpo, I don't know if the dumps are correct, but I did when
> the connection was stalled.

I would be better to have tcpdump running at least a bit back (2-3 windows 
back is long enough for me), but obviously that might not be possible 
option because it occurs so rarely. ...It should be possible to have 
tcpdump restarted once in a while to avoid a one huge log if you'd just 
keep running tcpdump from beginning.

> The problem is, when I dumped "eth0", the connection suddenly come back 
> alive again...

The situation (or some of those I did debug with other people) are such 
that they may indeed resolve themself, though I'm also interested why the 
slow part occurred.

> so, I don't know if it's useless or not:

What do you mean by "come back alive"...? ...In eth0 log I found this 
connection 189.38.18.122.995 > 192.168.0.2.35477, the ip matches with 
abusar's. But I'm not sure if the connection in the tunnel is the 
interesting one, since it's going to/from port 119 but the ip addresses 
(10.195.195.2 and 10.195.195.1) don't tell anything to me, I guess you 
know their meaning (ie., if 10.195.195.2 is the one with which the 
connection stalls)? ...You're probably right that this wasn't very useful 
log, the longest "stall" I find is only 1.111328 seconds long (and it 
might be due to some processing that is made by 10.195.195.2).

-- 
 i.
---696208474-1842071017-1218783999=:23522--
