From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 07/12] ixgbe: Enable timesync clock-out feature for
 PPS support on X540
Date: Fri, 11 May 2012 07:40:36 +0200
Message-ID: <20120511054036.GC2170@netboy.at.omicron.at>
References: <1336632413-19135-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1336632413-19135-8-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120510141721.GC3392@localhost.localdomain>
 <02874ECE860811409154E81DA85FBB5807794293@ORSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:56592 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752079Ab2EKFkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 01:40:47 -0400
Received: by bkcji2 with SMTP id ji2so1928599bkc.19
        for <netdev@vger.kernel.org>; Thu, 10 May 2012 22:40:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <02874ECE860811409154E81DA85FBB5807794293@ORSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 10, 2012 at 10:08:44PM +0000, Keller, Jacob E wrote:
> 
> Oops stupid mail program sent that on accident. Anyways: I think you might be
> right, Richard. We don't read those timestamp values unless the stat err bit
> for timestamps is set on the descriptor. But I am not sure what happens when the
> tjmestamped packet is dropped off the end of the ring. What would you propose
> here? How can we detect if this timestamp doesn't match the packet? I can look
> into using the extra hardware features for matching timestamps. That might be
> a more useful, in that it would help prevent this case.

[ Talking about the Rx time stamping locking from other patch... ]

The IGB provides some PTP event packet identification fields (seqNum,
etc) just for the purpose of matching time stamps to packets. Some of
the other PHC drivers (ixp4xx, dp83640) have code that does the
matching.

HTH,
Richard
