From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 10/13] igb: Tidy up wrapping for CONFIG_IGB_PTP.
Date: Thu, 23 Aug 2012 13:28:37 +0200
Message-ID: <20120823112837.GE2238@netboy.at.omicron.at>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1345715813-20757-11-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Matthew Vick <matthew.vick@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:46191 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753054Ab2HWL2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 07:28:43 -0400
Received: by bkwj10 with SMTP id j10so187568bkw.19
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 04:28:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1345715813-20757-11-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 23, 2012 at 02:56:50AM -0700, Jeff Kirsher wrote:
> From: Matthew Vick <matthew.vick@intel.com>
> 
> For users without CONFIG_IGB_PTP=y, we should not be compiling any PTP
> code into the driver. Tidy up the wrapping in igb to support this.

I would appreciate being put on Cc: for any PTP stuff.

Also, if you really want to improve the IGB driver, maybe you could
look at what happens to the time stamping when you do an ifdown/ifup
on the card. It seems to screw everything (observed on kernel 3.5).

Thanks,
Richard
