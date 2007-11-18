From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 crash
Date: Sun, 18 Nov 2007 22:00:38 +0100
Message-ID: <20071118210038.GA5907@electric-eye.fr.zoreil.com>
References: <20071117053920.M40084@nuclearcat.com> <20071117220759.GA2862@electric-eye.fr.zoreil.com> <20071117224224.M6133@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:52248 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751172AbXKRVCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Nov 2007 16:02:49 -0500
Content-Disposition: inline
In-Reply-To: <20071117224224.M6133@nuclearcat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denys <nuclearcat@nuclearcat.com> :
> 
> Before it happens on 2.6.22, i tried to attach good cable, plug-unplug, 
> whatever, interface up/down - card still remains dead.

A few things have changed since 2.6.22 but I'll take that it is a
real bug and that 2.6.23 would not recover either. Can you fill a
PR at http://bugzilla.kernel.org, add a lspci -vvvxxxx and a dmesg ?

A dmesg including the watchdog message would be nice but if you can
not retrieve one, a dmesg from your current 2.6.23.x kernel should be
enough.

I'll take care of it once I am done with the sis190 watchdog failure
(nothing hard, simply ugly).

[...]
> I try to plug cable to laptop with rtl8139 and pc with e100 - it is worked 
> when i shake bad cable(interface was going up/down as well), and good cable 
> also worked fine, and never crashed. On 2.6.22 i was able to reproduce it 
> easily, but later i can't cause it is server in internet cafe, and customers 
> going crazy.

:o/

-- 
Ueimor
