From: "Denys" <nuclearcat@nuclearcat.com>
Subject: Re: r8169 crash
Date: Mon, 19 Nov 2007 01:31:17 +0200
Message-ID: <20071118233010.M61920@nuclearcat.com>
References: <20071117053920.M40084@nuclearcat.com> <20071117220759.GA2862@electric-eye.fr.zoreil.com> <20071117224224.M6133@nuclearcat.com> <20071118210038.GA5907@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:59195 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752328AbXKSJd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 04:33:57 -0500
In-Reply-To: <20071118210038.GA5907@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Maybe it is good idea to print some registers/etc in watchdog message?

I will try to reproduce problem with debug enabled, maybe it will be possible 
to catch problem with more debug. 

On Sun, 18 Nov 2007 22:00:38 +0100, Francois Romieu wrote
> Denys <nuclearcat@nuclearcat.com> :
> > 
> > Before it happens on 2.6.22, i tried to attach good cable, plug-unplug, 
> > whatever, interface up/down - card still remains dead.
> 
> A few things have changed since 2.6.22 but I'll take that it is a
> real bug and that 2.6.23 would not recover either. Can you fill a
> PR at http://bugzilla.kernel.org, add a lspci -vvvxxxx and a dmesg ?
> 
> A dmesg including the watchdog message would be nice but if you can
> not retrieve one, a dmesg from your current 2.6.23.x kernel should be
> enough.
> 
> I'll take care of it once I am done with the sis190 watchdog failure
> (nothing hard, simply ugly).
> 
> [...]
> > I try to plug cable to laptop with rtl8139 and pc with e100 - it is 
worked 
> > when i shake bad cable(interface was going up/down as well), and good 
cable 
> > also worked fine, and never crashed. On 2.6.22 i was able to reproduce it 
> > easily, but later i can't cause it is server in internet cafe, and 
customers 
> > going crazy.
> 
> :o/
> 
> -- 
> Ueimor
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

