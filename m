From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Top 10 kernel oopses/warnings for the week of December 21st 2007
Date: Fri, 21 Dec 2007 14:57:36 +0100
Message-ID: <p73ejdgf8vj.fsf@bingen.suse.de>
References: <476BA8AF.4060201@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	Marcel Holtmann <marcel@holtmann.org>,
	"Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38542 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758978AbXLUN5j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Dec 2007 08:57:39 -0500
In-Reply-To: <476BA8AF.4060201@linux.intel.com> (Arjan van de Ven's message of "Fri\, 21 Dec 2007 12\:51\:11 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arjan van de Ven <arjan@linux.intel.com> writes:

> 	
> Rank 8: __change_page_attr
> 	BUG at arch/x86/mm/pageattr_64.c:176
> 	Reported 2 times
> 	Reported this week for 2.6.24-rc5; history goes back to 2.6.15

There is no BUG on this line on 2.6.24-rc5.   Since there are many
BUG_ONs in this file it is unclear which you mean.

Could you always include the version of the kernel where the actual
oops in the line came from?

Anyways there are a lot of third party modules who do strange 
things with c_p_a(), not always legal, so you might look up out for that 
pattern too. Perhaps report the out of tree modules loaded in the 
summary too?

-Andi

