From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: Re: kernel panic on 2.6.24 with esfq patch applied
Date: Sat, 02 Feb 2008 02:23:36 -0800
Message-ID: <47A444A8.8020304@fatooh.org>
References: <20080201131509.M52958@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:51215 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752263AbYBBKrU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Feb 2008 05:47:20 -0500
In-Reply-To: <20080201131509.M52958@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko wrote:
> Hi
> 
> Probably bug related to ESFQ, now i will unload module and will test more. 
> But probably not related, so if not difficult, please take a look.
> 
> Feb  1 09:08:50 SERVER [12380.067104] BUG: unable to handle kernel NULL 
> pointer dereference
> Feb  1 09:08:50 SERVER at virtual address 00000008
> Feb  1 09:08:50 SERVER [12380.067140] printing eip: c01f10ed
> Feb  1 09:08:50 SERVER *pde = 00000000
> Feb  1 09:08:50 SERVER
> Feb  1 09:08:50 SERVER [12380.067162] Oops: 0000 [#1]
> Feb  1 09:08:50 SERVER SMP
> Feb  1 09:08:50 SERVER
> Feb  1 09:08:50 SERVER [12380.067181] Modules linked in:
> Feb  1 09:08:50 SERVER netconsole
> Feb  1 09:08:50 SERVER configfs
> Feb  1 09:08:50 SERVER iTCO_wdt
> Feb  1 09:08:50 SERVER nf_nat_pptp
> Feb  1 09:08:50 SERVER nf_conntrack_pptp
> Feb  1 09:08:50 SERVER nf_conntrack_proto_gre
> Feb  1 09:08:50 SERVER nf_nat_proto_gre
> Feb  1 09:08:50 SERVER sch_esfq

I'd rather you were using my recent patches to SFQ instead of ESFQ. I
was able to crash a 2.6.24 user-mode Linux with ESFQ as well; I don't
know if that's what you encountered, but the SFQ patches should be
better anyway.

http://fatooh.org/esfq-2.6/sfq-2.6.24.tar.bz2
http://fatooh.org/esfq-2.6/

-Corey
