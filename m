From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 13/13] igb: Store the MAC address in the name in the
 PTP struct.
Date: Thu, 23 Aug 2012 12:45:54 +0200
Message-ID: <20120823104554.GA2238@netboy.at.omicron.at>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1345715813-20757-14-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Matthew Vick <matthew.vick@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:44571 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751233Ab2HWKp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 06:45:59 -0400
Received: by bkwj10 with SMTP id j10so172791bkw.19
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 03:45:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1345715813-20757-14-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 23, 2012 at 02:56:53AM -0700, Jeff Kirsher wrote:
> From: Matthew Vick <matthew.vick@intel.com>
> 
> Change the name of the adapter in the PTP struct to enable easier
> correlation between interface and PTP device.

You want to put the MAC address into the clock name? This is wrong.

Besides, there is no need for this. The ethool method already makes
the correlation crystal clear.

Thanks,
Richard
