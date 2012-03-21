From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [PATCH net V4 2/2] igb: offer a PTP Hardware Clock instead of
 the timecompare method
Date: Wed, 21 Mar 2012 17:09:06 +0000
Message-ID: <02874ECE860811409154E81DA85FBB580DA6E3@ORSMSX105.amr.corp.intel.com>
References: <D3F292ADF945FB49B35E96C94C2061B916484EC4@nsmail.netscout.com>
 <CAAsGZS4_owYK3NpdutP_6Lgfu453qmpQ8GO6i8FbG6V8wXafBg@mail.gmail.com>
 <20120316065537.GB2199@netboy.at.omicron.at>
 <CAAsGZS6=UsyiGK=ZOwRuY0CNR7aOFLrwpn-2hXEtQJbWEULciA@mail.gmail.com>
 <20120321170003.GA5533@netboy.at.omicron.at>
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
Received: from mga09.intel.com ([134.134.136.24]:2170 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757815Ab2CURJH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 13:09:07 -0400
In-Reply-To: <20120321170003.GA5533@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Wednesday, March 21, 2012 10:00 AM
> To: chetan loke
> Cc: netdev@vger.kernel.org; e1000-devel@lists.sourceforge.net; Keller, Jacob
> E; Kirsher, Jeffrey T; Ronciak, John; john.stultz@linaro.org;
> tglx@linutronix.de
> Subject: Re: [PATCH net V4 2/2] igb: offer a PTP Hardware Clock instead of the
> timecompare method
> 
> Can you please explain how using a seqlock could help here?
> 
> Thanks,
> Richard

My understanding of the seqlock, is that it prevents starvation of the hwtstamp calls in the rx and tx routines if/when a user hammers the gettime ioctl due to bad software design where 100+ apps are wanting direct access to the PHC.

- Jake
