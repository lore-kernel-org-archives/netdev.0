From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 1/6] igb: Tidy up wrapping for CONFIG_IGB_PTP.
Date: Thu, 6 Sep 2012 10:49:54 +0200
Message-ID: <20120906084954.GH2550@netboy.at.omicron.at>
References: <1346888106-25638-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1346888106-25638-2-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120906080938.GE2550@netboy.at.omicron.at>
 <1346921067.4228.12.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Matthew Vick <matthew.vick@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:44336 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751619Ab2IFIuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 04:50:06 -0400
Received: by bkwj10 with SMTP id j10so671483bkw.19
        for <netdev@vger.kernel.org>; Thu, 06 Sep 2012 01:50:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1346921067.4228.12.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 06, 2012 at 01:44:27AM -0700, Jeff Kirsher wrote:
> 
> As I recall, he stated he was going to integrate your suggestions in a
> new patch set that would follow this one.

Okay, but won't that mean moving the time stamping functions back, and
removing the #ifdefs again?

> Also, IMHO, while I look at pre-processor tags all day and get used to
> matching up #ifdef to #endif's, I still see #endif /* CONFIG_IGB_PTP */
> useful.  While it is not currently consistent, I see it more useful to
> fix as we go, rather than create a single patch to add a comment for
> every #endif.

Okay, fine.

Thanks,
Richard
