From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH] IPv6: Fix Prefix Length of Link-local Addresses
Date: Wed, 9 Oct 2002 20:16:39 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0210092015540.17906-100000@netcore.fi>
References: <20021010.015432.63506989.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: dfawcus@cisco.com, <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>,
   <usagi@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20021010.015432.63506989.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 10 Oct 2002, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:
> In article <20021009170018.H29133@edinburgh.cisco.com> (at Wed, 9 Oct 2002 17:00:18 +0100), Derek Fawcus <dfawcus@cisco.com> says:
> 
> > All link local's are currently supposed to have those top bits
> > ('tween 10 and 64) zero'd,  however any address within the link local
> > prefix _is_ on link / connected and should go to the interface.
> > 
> > i.e. it's perfectly valid for me to assign a link local of fe80:1910::10
> >      to an interface and expect it to be work,  likewise for a packet
> >      destined to any link local address to trigger ND.
> 
> First of all, please don't use such addresses.
> 
> By spec, auto-configured link-local address is fe80::/64
> and connected route should be /64.
> 
> If you do really want to use such addresses (like fe80:1920::10),
> you can put another route by yourself, at your own risk.
> 
> We should not configure in such way by default.
> and, we should even have to add "discard" route for them 
> by default for safe.

Personally I think the interfaces should be configured with a /64 but 
there should be a discard route for the whole /10.

-- 
Pekka Savola                 "Tell me of difficulties surmounted,
Netcore Oy                   not those you stumble over and fall"
Systems. Networks. Security.  -- Robert Jordan: A Crown of Swords
