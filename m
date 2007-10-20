From: Willy Tarreau <w@1wt.eu>
Subject: Re: ISNs and 2.6.22, Was: Re: haproxy & linux firewall (netfilter)
Date: Sat, 20 Oct 2007 23:52:01 +0200
Message-ID: <20071020215201.GA12894@1wt.eu>
References: <Pine.LNX.4.64.0710192358340.17074@bizon.gios.gov.pl> <20071020055604.GA1371@1wt.eu> <Pine.LNX.4.64.0710201422220.17074@bizon.gios.gov.pl> <20071020133101.GB3490@1wt.eu> <Pine.LNX.4.64.0710201544290.17074@bizon.gios.gov.pl> <20071020150035.GA12878@1wt.eu> <Pine.LNX.4.64.0710201853070.19637@bizon.gios.gov.pl> <Pine.LNX.4.64.0710201921000.19637@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: haproxy@formilux.org, netdev@vger.kernel.org
To: Krzysztof Oledzki <ole@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:3308 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750756AbXJUBgu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Oct 2007 21:36:50 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0710201921000.19637@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 20, 2007 at 07:23:25PM +0200, Krzysztof Oledzki wrote:
(...)
> >So it seems that ISNs are not randomly incremented but rather randomly 
> >generated. Adding netdev@vger.kernel.org to the CC list.
> 
> Eh, I was little to hurry this time. There were not randomly generated but 
> incremented with to big value. This patch fixes my problem:
> 
> http://git.kernel.org/?p=linux/kernel/git/stable/stable-queue.git;a=blob;f=queue-2.6.22/fix-tcp-initial-sequence-number-selection.patch;h=05b9167d68ecde1e6088f58c55e2906b768420ed;hb=HEAD

Good catch Krzysztof ! I've already noticed that one on LKML but did not
make the connection with your problem!

Please also tell Jozsef so that if he gets other reports, he knows where
to point the reporters.

Regards,
Willy

