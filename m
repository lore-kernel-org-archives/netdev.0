From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [RFC V1 1/1] net: cdc_ncm: Reduce memory use when kernel memory
 low
Date: Tue, 23 May 2017 10:42:48 +0200
Message-ID: <1495528968.2174.2.camel@suse.com>
References: <87shk4fynp.fsf@miraculix.mork.no>
         <20170517.141819.1307166900606639947.davem@davemloft.net>
         <04bc5b49-9282-a6ca-2b95-fb8fc9750555@mentor.com>
         <20170522.115426.1239443379414364630.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bjorn@mork.no, linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, jim_baxter@mentor.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41824 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933976AbdEWIoY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 04:44:24 -0400
In-Reply-To: <20170522.115426.1239443379414364630.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Montag, den 22.05.2017, 11:54 -0400 schrieb David Miller:
> 
> Unfortunately without a real notifier of some sort (there isn't one, and
> it isn't actually easy to come up with a clean way to do this which is
> probably why it doesn't exist yet in the first place) I really cannot
> recommend anything better.
> 
> That being said, probably for the time being we should just backoff each
> and every request, always trying initially to do the higher order thing.

We could use a counter. After the first failure, do it once, after the
second twice and so on. And reset the counter as a higher order
allocation works. (just bound it somewhere)

	Regards
		Oliver
