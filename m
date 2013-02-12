From: Larry Baker <baker@usgs.gov>
Subject: Re: decnet: /proc/sys/net/decnet sysctl entries disappear
Date: Tue, 12 Feb 2013 10:16:06 -0800
Message-ID: <730DD436-6FA8-4BB7-9FEB-5EE1F45D3A08@usgs.gov>
References: <FAAC90D7-8126-44CA-AACF-A5F8237C1A8E@usgs.gov> <20130211.200944.1447109432418679998.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v1085)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gscamnlh01.wr.usgs.gov ([130.118.9.68]:43639 "EHLO
	gscamnlh01.wr.usgs.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933398Ab3BLSQH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 13:16:07 -0500
In-Reply-To: <20130211.200944.1447109432418679998.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

On 11 Feb 2013, at 5:09 PM, David Miller wrote:

> 
> Attachments are not the correct way to submit a series of patches.
> 
> Please read Documentation/SubmittingPatches
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

I found scripts/get_maintainer.pl lists you as a maintainer of the decnet code.  It also lists Chrissie Caulfield, but she has pretty much bowed out -- she's the one that told me to send my patches to the net-dev list.

To make this go as smoothly as possible, I'd like your advice about what I should do.  So, my first question is: should I submit a bug report describing the faulty behavior and my diagnosis while I work on pruning my patches?  To netdev@vger.kernel.org?  Second: I made three patch files to account for the API changes to the kernel over time.  Should those be individual submissions, related somehow by the tag in [PATCH tag]?  Suggestions?

Who changes the banner, me or you?  Do you have a recommendation for choosing the version in the banner?

Eric Biederman fixed the root cause of the faulty behavior in kernel 3.4-rc1.  None of my systems are that new.  He told me about patching stable kernels.

> But there are people who collect bug fixes and apply them to older
> kernels as long as a fix has been made to Linus's kernel and I would
> be happy to do a bit of code review and forward those patches
> to stable@vger.kernel.org if you that is what you are interested in
> doing with them.


Since the current kernel code has apparently fixed the problem, should I send my work to Eric/stable@vger.kernel.org instead of netdev@vger.kernel.org?  I do not want to annoy anyone with issues that might seem trivial to most people -- most people have probably never heard of DECnet.

Thank you in advance for your time.

Larry Baker
US Geological Survey
650-329-5608
baker@usgs.gov
