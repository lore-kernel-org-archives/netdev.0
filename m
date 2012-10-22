From: "N, Mugunthan V" <mugunthanvnm@ti.com>
Subject: RE: [PATCH 5/6] drivers: net: ethernet: cpts: implement cpts
 hardware clock
Date: Mon, 22 Oct 2012 10:55:55 +0000
Message-ID: <EB1619762EAF8B4E97A227FB77B7E0293E9FD709@DBDE01.ent.ti.com>
References: <1350427518-7230-1-git-send-email-mugunthanvnm@ti.com>
 <1350427518-7230-6-git-send-email-mugunthanvnm@ti.com>
 <20121020134331.GA5444@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:59895 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688Ab2JVK4A convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 06:56:00 -0400
In-Reply-To: <20121020134331.GA5444@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Saturday, October 20, 2012 7:14 PM
> To: N, Mugunthan V
> Cc: netdev@vger.kernel.org; davem@davemloft.net
> Subject: Re: [PATCH 5/6] drivers: net: ethernet: cpts: implement cpts
> hardware clock
> 
> 
> I did a careful read of this driver, and I found a number of issues,
> but I am not giving a line by line review, for reasons explained
> below. For the most part, your driver is very similar to mine, and
> your driver would probably work fine too, when given a bit of review
> and revision. However, in the end, it would end up looking nearly
> identical to mine.
> 
> The issues about which you have voiced concern (counter roll over,
> changing input clock frequency) are by no means unique to the CPTS.
> The existing PHC drivers all handle these issues in a way consistent
> with each other. New drivers should not invent their own solutions to
> such problems.
> 
> If I had never written a CPTS driver and had seen your present
> submission first, then I would be willing to help you get your driver
> merged. But in my view, this work is already done, and so I am favoring
> my own driver at this point.
> 
> Here is my suggestion for moving forward with support the CPTS:
> 
> - It is too early to support the CPTS v1 found on the DM81xx, since
>   the CPSW support (including DT) is totally lacking. Judging from
>   your present driver and the TRM, the differences are minimal and
>   will be easy to add later on. For now, we can simply check the
>   version register for v2.
> 
> - If you can get the patches needed to get the CPSW working merged
>   during the present v3.7-rc interval, that would form a basis for
>   getting the CPTS into v3.8. I tried to post the patches that I had
>   collected, but I failed to get them all accepted. I really don't
>   know the issues surrounding those patches at all, and so I would
>   appreciate if you would take the lead and get this support merged.
> 
> - I will add a version check for CPTS v2 and integrate your CPSW
>   multicast patch (and anything else you think is missing) into my own
>   patch series. Once your background patches have appeared, I will
>   post the CPTS series for net-next, in time for v3.8.

The CPTS found in DM81XX and AM335X is of same version, only the CPSW version
is different in both SoCs.

Regards
Mugunthan V N

> 
> - Looking ahead, once you get a patch series to fully support the
>   DM81xx CPSW, we can patch the CPTS too.
> 
> Thanks,
> Richard
