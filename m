From: "Alexander Duyck" <alexander.duyck@gmail.com>
Subject: Re: [UPDATED PATCH] ixgbe: fix vlan filtering
Date: Tue, 26 Aug 2008 20:21:35 -0700
Message-ID: <9A26C12C7CD54EFEA0BF27CA1D55005B@ADUYCKLAPTOP>
References: <20080827013004.5497.48208.stgit@jtkirshe-mobile.jf.intel.com> <20080826191201.9689dd7d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <jeff@garzik.org>, <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<stable@kernel.org>,
	"Alexander Duyck" <alexander.h.duyck@intel.com>,
	"Jesse Brandeburg" <jesse.brandeburg@intel.com>
To: "Andrew Morton" <akpm@linux-foundation.org>,
	"Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:4493 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752527AbYH0DWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 23:22:52 -0400
Received: by wf-out-1314.google.com with SMTP id 27so2580612wfd.4
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 20:22:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Please note that this patch does not successfully apply to 2.6.25 nor
> to 2.6.26.  I didn't check why.
>
> The -stable maintainers might appreciate separate checked-and-tested
> backports for those kernels.
>
> Thanks.

Actually I don't believe this applies to any kernels prior to 2.6.27-rc1. 
It looks like the commit that broke this in the first place 
(http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=746b9f0228a1c607b3db67c80da1c2a963321926) 
was added to the torvalds tree on July 17th and 2.6.26 was released about a 
week before.

Sorry about not putting much of a changelog in for this.  It was something I 
found as a side issue while working on something else, I set it aside and 
kept working on my patches.  I forgot to come back and put a description in 
there other than what was wrong prior to forwarding it to Jeff K.

Thanks,

Alex 

