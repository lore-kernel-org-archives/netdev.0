From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH|RFC] IPv6 netfilter: a module for complete proxy ND
 support
Date: Thu, 15 Jan 2004 17:42:38 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0401151740400.16820-100000@netcore.fi>
References: <Pine.LNX.4.58.0401151719160.29722@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>,
        <netfilter-devel@lists.netfilter.org>, <davem@redhat.com>,
        <netdev@oss.sgi.com>, <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.58.0401151719160.29722@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 15 Jan 2004, Ville Nuorvala wrote:
> In the current implementation the proxying router captures the multicast
> queries since it has joined the solicited-node multicast group, but it
> doesn't capture the unicast queries.
> 
> This is what I want to fix.

But isn't this like a trivial thing to do, hardly something you want 
to add a netfilter dependency for?

In addition to cycling through your own addresses for responding to 
unicast queries, you also respond to a specific set of addresses which 
have been explicitly configured somewhere? (with a configuration tool 
like 'arp', e.g. KAME has 'ndp' for that)

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
