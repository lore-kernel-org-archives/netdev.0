From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH|RFC] IPv6: have a proxy discard link-local traffic
Date: Wed, 28 Jan 2004 07:26:48 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0401280725370.14588-100000@netcore.fi>
References: <20040128.085414.32889499.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: vnuorval@tcs.hut.fi, <davem@redhat.com>, <usagi-core@linux-ipv6.org>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20040128.085414.32889499.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 28 Jan 2004, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:
> In article <Pine.LNX.4.58.0401272259160.28384@rhea.tcs.hut.fi> (at Tue, 27 Jan 2004 23:11:20 +0200 (EET)), Ville Nuorvala <vnuorval@tcs.hut.fi> says:
> > +	/* The proxying router can't forward traffic sent to a link-local
> > +	   address, so signal the sender and discard the packet. This
> > +	   behavior is required by the MIPv6 specification. */
> 
> Would you please clarify the word "can't" and its reasons?
> won't? don't? or whatever?

I think "can't" in this context means, "it can't be _forwarded_
because it's link-local".  It could be proxied using some other
function than ip6_forward, though.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
