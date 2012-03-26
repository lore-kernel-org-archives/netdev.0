From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [PATCH net V4 2/2] igb: offer a PTP Hardware Clock instead of
 the timecompare method
Date: Mon, 26 Mar 2012 20:51:28 +0000
Message-ID: <02874ECE860811409154E81DA85FBB580DC1C2@ORSMSX105.amr.corp.intel.com>
References: <CAAsGZS4_owYK3NpdutP_6Lgfu453qmpQ8GO6i8FbG6V8wXafBg@mail.gmail.com>
 <20120316065537.GB2199@netboy.at.omicron.at>
 <CAAsGZS6=UsyiGK=ZOwRuY0CNR7aOFLrwpn-2hXEtQJbWEULciA@mail.gmail.com>
 <20120321170003.GA5533@netboy.at.omicron.at>
 <02874ECE860811409154E81DA85FBB580DA6E3@ORSMSX105.amr.corp.intel.com>
 <CAAsGZS6QuMJoXz8mmqZsgfTF2ykRz6KG_nCoPBBkTA4z3idoGA@mail.gmail.com>
 <20120322064107.GB2182@netboy.at.omicron.at>
 <CAAsGZS6A3Cz9eb9v94MKTeonW0YitHh5h7owpkRofKzgzUKF_Q@mail.gmail.com>
 <02874ECE860811409154E81DA85FBB580DB92C@ORSMSX105.amr.corp.intel.com>
 <CAAsGZS460uazL5n=oc3DwWKqeuTtNdQROGXQrPbs=Qh92TpnDg@mail.gmail.com>
 <20120324065147.GB2201@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>
To: Richard Cochran <richardcochran@gmail.com>,
	chetan loke <loke.chetan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:26997 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756894Ab2CZUv3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 16:51:29 -0400
In-Reply-To: <20120324065147.GB2201@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Friday, March 23, 2012 11:52 PM
> To: chetan loke
> Cc: Keller, Jacob E; netdev@vger.kernel.org; e1000-
> devel@lists.sourceforge.net; Kirsher, Jeffrey T; Ronciak, John;
> john.stultz@linaro.org; tglx@linutronix.de
> Subject: Re: [PATCH net V4 2/2] igb: offer a PTP Hardware Clock instead of the
> timecompare method
> 
> > How about rate limiting at the PHC class driver level? And then it
> > will work across the board for all the adapters at the device level.
> 
> No, don't go there. Enough bikeshedding already. If you have a serious
> performance issue, please post a test case, and we will look for a solution.
> 

This is about a case where the user does something stupid. (runs the ioctls too
fast). It appears that your answer is something like "The user did something
stupid, we shouldn't care". My answer is, "we should do what we can to prevent
this." I don't think modifying the ptp framework is necessary or even a good
idea. (Because it is a particular issue with intel parts design, not with general
PTP design.) I do think if possible we should modify igb/ixgbe patches properly
to prevent the breaking. I am currently working on a test case where the user
*does* hammer the ioctls and seeing whether that actually crashes the driver.

> Thanks,
> Richard
> 
