From: Martin Michlmayr <tbm@cyrius.com>
Subject: Re: r8169 driver problem with RTL8110SB chip (on iop3xx ARM board)
Date: Thu, 3 Aug 2006 15:53:49 +0200
Message-ID: <20060803135349.GH31534@deprecation.cyrius.com>
References: <20060728101109.GA25854@xi.wantstofly.org> <20060728104946.GA6710@electric-eye.fr.zoreil.com> <20060728111534.GD25854@xi.wantstofly.org> <20060728115237.GF21733@deprecation.cyrius.com> <20060728194933.GA14222@electric-eye.fr.zoreil.com> <20060728203437.GA6253@deprecation.cyrius.com> <20060802180244.GA32235@deprecation.cyrius.com> <20060802221629.GB28282@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sorrow.cyrius.com ([65.19.161.204]:38411 "EHLO
	sorrow.cyrius.com") by vger.kernel.org with ESMTP id S932139AbWHCNyA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 09:54:00 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20060802221629.GB28282@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Francois Romieu <romieu@fr.zoreil.com> [2006-08-03 00:16]:
> 0x37: Command                                       0x00
>       Rx off, Tx off
> > 55	0x0c
>           ^^ -> CmdRxEnb | CmdTxEnb
> 
> If ChipCmd is not set, the driver will hardly work.

I put in a printk and ChipCmd is definitely being set but when I query
it with ethtool later it is 0x00.  What might reset it?


CmdTxEnb: 0x4
CmdTxEnb: 0x8
ChipCmd (before): 0x0
ChipCmd (after): 0xc
r8169: eth0: link up

-- 
Martin Michlmayr
http://www.cyrius.com/
