From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH] IPv6: Privacy Extensions for Stateless Address
 Autoconfiguration in IPv6
Date: Thu, 31 Oct 2002 09:43:40 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0210310942030.19356-100000@netcore.fi>
References: <20021031.163209.595697847.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, <netdev@oss.sgi.com>, <davem@redhat.com>,
   <kuznet@ms2.inr.ac.ru>, <usagi@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20021031.163209.595697847.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 31 Oct 2002, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:
> In article <Pine.LNX.4.44.0210310908090.19356-100000@netcore.fi> (at Thu, 31 Oct 2002 09:25:01 +0200 (EET)), Pekka Savola <pekkas@netcore.fi> says:
> 
> > I belive privacy extensions can be harmful for especially long-lived
> > applications and lead to a false sense of security: they should not be
> > enabled (by any definition of enabled) by default.
> 
> Temporary addresses are generated (on most links) but not used by default 
> (latter is done by source address selection) by my patch.  
> Set sysctl net.ipv6.conf.ethXX.use_tempaddr > 1 to use it by default.
> 
> (I have per-application setsockopt interface but it is not included 
>  because patch for source address selection is not accepted at this moment.)

Generating and re-generating new temporary addresses seems to be a useless 
work and just new addresses unless they're being used at least by some 
applications.

-- 
Pekka Savola                 "Tell me of difficulties surmounted,
Netcore Oy                   not those you stumble over and fall"
Systems. Networks. Security.  -- Robert Jordan: A Crown of Swords
