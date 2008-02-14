From: Claudio Lanconelli <lanconelli.claudio@eptar.com>
Subject: Re: [patch 2.6.24-git] net/enc28j60: oops fix, low power mode
Date: Thu, 14 Feb 2008 11:28:29 +0100
Message-ID: <47B417CD.6040805@eptar.com>
References: <20080205190124.E72F48E45F@adsl-69-226-248-13.dsl.pltn13.pacbell.net> <200802100954.18225.david-b@pacbell.net> <47B03A9A.2060605@eptar.com> <200802111223.49823.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fe-relay01.albacom.net ([217.220.57.138]:1384 "EHLO
	fe-relay01.albacom.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752675AbYBNK1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2008 05:27:15 -0500
In-Reply-To: <200802111223.49823.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Brownell wrote:
> On Monday 11 February 2008, Claudio Lanconelli wrote:
>   
>> I have tried your latest patch. Only after the following change it
>> works fine (no more rx errors during ifconfig up).
>>     
>
> Hmm, what chip rev do you have?  Different errata and all.
> ISTR mine is rev4; so, not the most current, but not the
> oldest version either.
>   
I use the same revision.

>> I added enc28j60_lowpower(false) just before enc28j60_hw_init()
>>     
>
> Hmm, I'd have expected it would go best *before* that, but
> what you include below shows it going *after* ...
>
> If there's some problem where reset doesn't work correctly
> in low power mode, who knows what else would need manual
> resetting.
>
>   
I don't know why it needs low power resume before reset.
I read in the errata tath clkready bit after reset doesn't work reliably.
May be something related to this, but undocumented.

> Better yet, since I can't reproduce the problem, why don't
> you just update my latest patch with the relevant version
> of this tweak, and then forward it as "From: " me and with
> both our signoffs.  That's the usual way to cope with this
> type of tweaking.  (Not all updates to your driver should
> need your signoff, but then most patches shouldn't need
> very many iterations either.)
>   
Done

