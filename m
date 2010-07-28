From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] bnx2x: move bnx2x to separate folder and
 divide to files
Date: Tue, 27 Jul 2010 20:56:40 -0700 (PDT)
Message-ID: <20100727.205640.235673886.davem@davemloft.net>
References: <1280270447.11551.119.camel@lb-tlvb-dmitry>
	<20100727.203640.173839576.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58649
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752412Ab0G1D4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 23:56:22 -0400
In-Reply-To: <20100727.203640.173839576.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 27 Jul 2010 20:36:40 -0700 (PDT)

> From: "Dmitry Kravkov" <dmitry@broadcom.com>
> Date: Wed, 28 Jul 2010 01:40:47 +0300
> 
>> resubmit the series with fixes for git-apply. Thanks
> 
> All applied, thanks.

Ummm, so what in the world did you think was going to happen
the next time I try to merge net-2.6 into net-next-2.6?

Any clue what might happen?

Any idea?

Since you not only moved the driver into a new directory,
but also moved functions all over the damn place into new
files too, the bnx2x bug fixes in net-2.6 have to be applied
by hand by me during the merge, bit by bit.

This is one of the millions of reasons I absolutely detest multi-file
drivers, people move crap around, patches from one tree can't easily
be munged into another, etc.

If it's too big to fit in one file, your driver is too damn bloated.
End of story.  Put the thing into one file under drivers/net and
simplify _everyones_ life.

I'm fixing this merge mess up, but I'm very not happy about how
you guys staged this sequence of events.
