From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: Top 10 kernel oopses/warnings for the week of December 21st 2007
Date: Fri, 21 Dec 2007 15:30:45 +0100
Message-ID: <476BCE15.6090902@linux.intel.com>
References: <476BA8AF.4060201@linux.intel.com> <p73ejdgf8vj.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	Marcel Holtmann <marcel@holtmann.org>,
	"Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:37554 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750920AbXLUOch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 09:32:37 -0500
In-Reply-To: <p73ejdgf8vj.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> Arjan van de Ven <arjan@linux.intel.com> writes:
> 
>> 	
>> Rank 8: __change_page_attr
>> 	BUG at arch/x86/mm/pageattr_64.c:176
>> 	Reported 2 times
>> 	Reported this week for 2.6.24-rc5; history goes back to 2.6.15
> 
> There is no BUG on this line on 2.6.24-rc5.   Since there are many
> BUG_ONs in this file it is unclear which you mean.
> 
> Could you always include the version of the kernel where the actual
> oops in the line came from?

in this case this is really all the version information available ;(
it seems to be a patched kernel without patched EXTRAVERSION.
But in the future if I have more specific information (eg it's only 1 kernel version) I'll mention it in more detail.
It gets unwieldy if there's 500 reports for an oops of course ;)

> 
> Anyways there are a lot of third party modules who do strange 
> things with c_p_a(), not always legal, so you might look up out for that 
> pattern too. Perhaps report the out of tree modules loaded in the 
> summary too?

I already always will mention if the oops is tainted or not (that I track specifically);
I'll keep an eye out for other non-tainting out of tree modules as well.

Thanks for the suggestions.

