From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND PATCH v5 1/2] can: rcar_canfd: Add Renesas R-Car CAN
 FD driver
Date: Fri, 03 Jun 2016 11:39:02 -0700 (PDT)
Message-ID: <20160603.113902.296916236989519473.davem@davemloft.net>
References: <KL1PR06MB1031E61B9DD9A59B305CCC15C3590@KL1PR06MB1031.apcprd06.prod.outlook.com>
	<CAO3366wxRkRZyR3nayY5=7sTxk-pWZ-BRjXA7p8OzvuZ-YbvDw@mail.gmail.com>
	<5751BB31.5030708@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ulrich.hecht@gmail.com, ramesh.shanmugasundaram@bp.renesas.com,
	mkl@pengutronix.de, wg@grandegger.com, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, Chris.Paterson2@renesas.com,
	horms@verge.net.au, magnus.damm@gmail.com,
	linux-renesas-soc@vger.kernel.org
To: socketcan@hartkopp.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5751BB31.5030708@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Fri, 3 Jun 2016 19:15:29 +0200

> On 06/03/2016 07:03 PM, Ulrich Hecht wrote:
> 
>> Thanks; I missed that every register is described twice.
>>
>> Nevertheless, names often vary more or less subtly between your patch
>> and the specs, making it very hard to review. Some have letters added,
>> some have letters removed, and some are just plain confusing. For
>> instance, RCANFD_DCFG_* apparently does not describe, as one might
>> think, RSCFDnCFDCmDCFG, but RSCFDnCFDCmFDCFG. These names are, of
>> course, completely ridiculous, but inventing a new set makes things
>> even worse, IMO.
> 
> ???
> 
> You suggest to use 'completely ridiculous' definitions in favor to
> definitions that have a proper name space RCANFD_ ?
> 
> When there is a more readable way that maintains proper readable code
> there's no reason to adopt crappy definitions just because some chip
> designer has no clue how to design proper register names.
> 
> When there's some mapping from RSCFDnCFDCmFDCFG to RCANFD_DCFG_* this
> could be mentioned in the comments.
> 
> But I'm totally against these blurry upper/lower case letter stuff for
> register definitions.

I agree with Oliver, these StuDlyCaPS names used in the spec should
not be used in the driver, they are completely unreadable.
