From: "Ruslan N. Marchenko" <me@ruff.mobi>
Subject: Re: 802.1Q VLAN random tag injected when vlan configured on
 forcedeth interface
Date: Tue, 30 Aug 2011 16:23:10 +0200
Message-ID: <20110830142310.GC28341@ruff.mobi>
References: <20110830125111.GA28341@ruff.mobi>
 <1314710628.2935.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20110830134624.GB28341@ruff.mobi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip-89-176-12-106.net.upcbroadband.cz ([89.176.12.106]:60258
	"EHLO ruff.mobi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754454Ab1H3OXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 10:23:12 -0400
Content-Disposition: inline
In-Reply-To: <20110830134624.GB28341@ruff.mobi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 30, 2011 at 03:46:24PM +0200, Ruslan N. Marchenko wrote:
> On Tue, Aug 30, 2011 at 03:23:48PM +0200, Eric Dumazet wrote:
> > 
> > What kernel version are you using ?
> > 
> Oh, sorry for missing it, it runs on 
> Linux ruff.mobi 2.6.38-11-generic #48-Ubuntu SMP Fri Jul 29 19:05:14 UTC 2011 i686 i686 i386 GNU/Linux
> 
> Just fyi - the openwrt box to which it is connected is 
> Linux OpenWrt 2.6.39.2 #2 Fri Aug 12 09:36:23 EEST 2011 mips GNU/Linux
> although packet drop happens even if there're no vlans configured on remote side.
> 
Here is double-tag sample:
16:20:31.151268 e0:46:9a:4e:88:1d > 00:26:18:40:21:62, ethertype 802.1Q (0x8100), length 106: vlan 2112, p 7, ethertype 802.1Q, vlan 6, p 0, ethertype IPv4, [|ip]
        0x0000:  0026 1840 2162 e046 9a4e 881d 8100 e840
        0x0010:  8100 0006 0800 4500 0054 abec 0000


Regards,
Ruslan
