From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Allow Both IPv6 and IPv4 Sockets on the Same Port
Date: Thu, 03 Oct 2002 08:04:08 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021003.080408.78030688.davem@redhat.com>
References: <200210031301.RAA29267@sex.inr.ac.ru>
	<20021003.231534.83777766.yoshfuji@linux-ipv6.org>
	<20021004.000631.28088811.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20021004.000631.28088811.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Fri, 04 Oct 2002 00:06:31 +0900 (JST)

   In article <20021003.231534.83777766.yoshfuji@linux-ipv6.org> (at Thu, 03 Oct 2002 23:15:34 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:
   
   > In article <200210031301.RAA29267@sex.inr.ac.ru> (at Thu, 3 Oct 2002 17:01:11 +0400 (MSD)), kuznet@ms2.inr.ac.ru says:
   > 
   > > While doing *_get_port() daddr/dport are _unknown_ and always zero,
   > > so it never works.
   > > 
   > > Please, remove these bits, the patch will become simpler.
   > 
   > Ok, I'll do that.
   
   I remember that test for daddr is for existing sockets, 
   not for socket doing XXX_get_port().
   So, I think I don't need to remove that.

Where can daddr/dport be non-zero during get_port()?
