From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH][E1000E] some cleanups
Date: Sun, 30 Sep 2007 15:01:21 -0400
Message-ID: <1191178881.6165.40.camel@localhost>
References: <1191174077.6165.11.camel@localhost>
	 <46FFE809.8020504@intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.228]:39083 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880AbXI3TBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Sep 2007 15:01:25 -0400
Received: by wx-out-0506.google.com with SMTP id h31so3038748wxd
        for <netdev@vger.kernel.org>; Sun, 30 Sep 2007 12:01:24 -0700 (PDT)
In-Reply-To: <46FFE809.8020504@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-30-09 at 11:16 -0700, Kok, Auke wrote:

> no, all the hardware that is commented should work just fine. I tested this driver
> on 82571, 82573 and ich8/ich9 - extensively.

Something else is wrong then. Can you just uncomment the 82571EB bits in
Dave's net-2.6.24 and just send a ping? If it works, let me know what
you did so i can test next time i get a chance.

> the reason that we disable them is that we're going to migrate devices over in
> batches. At introduction we'll support ich9, afterwards we'll drop in the IDs of
> the other groups of silicon.

Turn them on if you want people to start using that driver.

> > Once you have 82571EB on and kicking, my next steps are to kill LLTX
> > then add batching on top.
> > BTW, since this driver is just for PCIE, would you take a similar patch
> > for non-PCIE e1000?
> 
> if it's a fix, yes.

It just makes it easier to kill LLTX. If you consider killing LLTX
risky, then i will focus on e1000e.

cheers,
jamal

