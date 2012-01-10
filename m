From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next V3 1/2] igb: add PTP Hardware Clock code
Date: Tue, 10 Jan 2012 09:44:50 +0100
Message-ID: <20120110084450.GA5356@cherladcori01>
References: <cover.1325964581.git.richardcochran@gmail.com>
 <06a2d33bed05d5c17c03fca6f0fcc2fe3f6870f4.1325964581.git.richardcochran@gmail.com>
 <02874ECE860811409154E81DA85FBB5801E86F@ORSMSX106.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:49618 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499Ab2AJIpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2012 03:45:04 -0500
Received: by wibhm6 with SMTP id hm6so3196770wib.19
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2012 00:45:03 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <02874ECE860811409154E81DA85FBB5801E86F@ORSMSX106.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 09, 2012 at 05:42:20PM +0000, Keller, Jacob E wrote:

> Is there a reason for not using the timecounter structure from the
> kernel? It is a layer beneath the timecompare code which is meant to
> handle this condition. As far as I can tell this issue is solved in
> the timecounter code. If it is not, then that should be a bug in the
> timecounter cyclecounter code. I don't know if this issue occurs in
> the timecounter structure because it handles the ns conversion
> differently.

My only reason is that I am not sure that the timecounter code really
does what we need.  It might well work.  Consider, though, that the
82580 register does not overflow in the usual way. The upper 24 bits
are always zero.

What I wrote does the right thing, I think.  However, duplicated
effort is always bad, so can you show me how to change it?

Thanks,
Richard
