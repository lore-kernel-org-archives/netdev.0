From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 0/6][pull request] Intel Wired LAN Driver Updates
Date: Thu, 6 Sep 2012 10:13:15 +0200
Message-ID: <20120906081315.GF2550@netboy.at.omicron.at>
References: <1346888106-25638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:41880 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752310Ab2IFIN1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 04:13:27 -0400
Received: by bkwj10 with SMTP id j10so652436bkw.19
        for <netdev@vger.kernel.org>; Thu, 06 Sep 2012 01:13:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1346888106-25638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 05, 2012 at 04:35:00PM -0700, Jeff Kirsher wrote:
> 
> Matthew Vick (6):
>   igb: Tidy up wrapping for CONFIG_IGB_PTP.
>   igb: Update PTP function names/variables and locations.
>   igb: Correct PTP support query from ethtool.
>   igb: Store the MAC address in the name in the PTP struct.

These four still look like unnecessary churn to me, and possibly the
wrong direction WRT time stamping in the 82580.

>   igb: Prevent dropped Tx timestamps via work items and interrupts.
>   igb: Add 1588 support to I210/I211.

But these two look important, so I don't know what to say.

Sorry,
Richard
