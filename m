From: Roland Dreier <roland@digitalvampire.org>
Subject: Re: [PATCH] [ATM] he: Fix __init/__devinit conflict
Date: Sun, 24 Sep 2006 20:37:41 -0700
Message-ID: <87bqp4ty4a.fsf@digitalvampire.org>
References: <877j0a5i6v.fsf@digitalvampire.org>
	<87fyeit8wd.fsf@digitalvampire.org>
	<20060924.201118.71090751.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from rwcrmhc11.comcast.net ([204.127.192.81]:6649 "EHLO
	rwcrmhc11.comcast.net") by vger.kernel.org with ESMTP
	id S1751452AbWIYDhn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Sep 2006 23:37:43 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060924.201118.71090751.davem@davemloft.net> (David Miller's
 message of "Sun, 24 Sep 2006 20:11:18 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    David> I was waiting for a resolution in the fact that the copy
    David> Chas posted only had one of the transformations whereas as
    David> you pointed out all of the ones in your original patch were
    David> necessary.

Actually I think there was some confusion because akpm forwarded a
patch from someone else that just changed one __init -> __devinit
(which appeared to fix things at least on x86_64 because of the
effects of -funit-at-a-time).

I'm not positive but as far as I remember Chas sent my original patch.

Anyway, I think we've wasted enough time on a trivial warning patch.

 - R.
