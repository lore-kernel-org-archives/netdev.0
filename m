From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [RESEND PATCH v5 1/2] can: rcar_canfd: Add Renesas R-Car CAN FD
 driver
Date: Fri, 3 Jun 2016 19:15:29 +0200
Message-ID: <5751BB31.5030708@hartkopp.net>
References: <1456824849-7987-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <1464860702-46087-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <1464860702-46087-2-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <CAO3366wP+tBaGbrMceupcJu0agW5Euo3NBNwijNCmpM1XcDGmQ@mail.gmail.com>
 <KL1PR06MB1031E61B9DD9A59B305CCC15C3590@KL1PR06MB1031.apcprd06.prod.outlook.com>
 <CAO3366wxRkRZyR3nayY5=7sTxk-pWZ-BRjXA7p8OzvuZ-YbvDw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "mkl@pengutronix.de" <mkl@pengutronix.de>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chris Paterson <Chris.Paterson2@renesas.com>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	"linux-renesas-soc@vger.kernel.org"
	<linux-renesas-soc@vger.kernel.org>
To: Ulrich Hecht <ulrich.hecht@gmail.com>,
	Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <CAO3366wxRkRZyR3nayY5=7sTxk-pWZ-BRjXA7p8OzvuZ-YbvDw@mail.gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/03/2016 07:03 PM, Ulrich Hecht wrote:

> Thanks; I missed that every register is described twice.
>
> Nevertheless, names often vary more or less subtly between your patch
> and the specs, making it very hard to review. Some have letters added,
> some have letters removed, and some are just plain confusing. For
> instance, RCANFD_DCFG_* apparently does not describe, as one might
> think, RSCFDnCFDCmDCFG, but RSCFDnCFDCmFDCFG. These names are, of
> course, completely ridiculous, but inventing a new set makes things
> even worse, IMO.

???

You suggest to use 'completely ridiculous' definitions in favor to 
definitions that have a proper name space RCANFD_ ?

When there is a more readable way that maintains proper readable code 
there's no reason to adopt crappy definitions just because some chip 
designer has no clue how to design proper register names.

When there's some mapping from RSCFDnCFDCmFDCFG to RCANFD_DCFG_* this 
could be mentioned in the comments.

But I'm totally against these blurry upper/lower case letter stuff for 
register definitions.

Regards,
Oliver


>
> At least for the bits, I'd stick with the names given in the
> datasheet. They usually make a modicum of sense, and it makes it way
> easier to search for them. It would also help if the bits were sorted
> consistently.
>
> CU
> Uli
>
