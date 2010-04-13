From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Linux arp flux problem
Date: Tue, 13 Apr 2010 11:26:32 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.1004131118290.2767@u.domain.uli>
References: <908408.23515.qm@web31502.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Net Dev <netdev@vger.kernel.org>
To: Ming-Ching Tiew <mctiew@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [178.16.129.10] ([178.16.129.10]:43906 "EHLO u.domain.uli"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751059Ab0DMIcE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Apr 2010 04:32:04 -0400
In-Reply-To: <908408.23515.qm@web31502.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sun, 11 Apr 2010, Ming-Ching Tiew wrote:

> The following link explains the Linux arp flux problem pretty well, and I myself have been burnt badly by a life site where the "arp_filter" does not help at all.
> 
>          http://linux-ip.net/html/ether-arp.html
> 
> And I tested the kernel patch by Julian Anastasov, and it works 100% reliably :-
> 
>          http://www.ssi.bg/~ja/#hidden
> 
> My question is the patches has been around for many years, why has it not been included into the kernel ? Is it that Linux is supposed to have this "side effects" of arp linux on purpose ?

	The "hidden" flag is obsolete, kernel already has arp_ignore
and arp_announce vars, see Documentation/networking/ip-sysctl.txt
for more information. May be what you need is arp_announce=1/2
and (arp_ignore=1/2 or arp_filter=1 or rp_filter=1).

Regards

--
Julian Anastasov <ja@ssi.bg>
