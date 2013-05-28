From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: igb: acknowledging time sync interrupts
Date: Tue, 28 May 2013 18:06:54 +0200
Message-ID: <20130528160654.GC4678@netboy>
References: <20130526103900.GA11682@netboy>
 <CDCA1885.1E850%matthew.vick@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Vick, Matthew" <matthew.vick@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f182.google.com ([74.125.82.182]:43761 "EHLO
	mail-we0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934630Ab3E1QHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 12:07:03 -0400
Received: by mail-we0-f182.google.com with SMTP id q57so5353270wes.27
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 09:07:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CDCA1885.1E850%matthew.vick@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 28, 2013 at 03:20:10PM +0000, Vick, Matthew wrote:
> 
> I'll start some internal discussion to see if I can get an official answer
> on the 82580.

Okay, that sounds good. I just posted a patch that removes the wr32(),
and I can report that it does work on the i210. If the 82580 needs
this workaround, then I can add it back in again.

Thanks,
Richard
