From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH] SMSC LAN911x and LAN921x vendor driver
Date: Mon, 02 Jun 2008 20:32:30 +0200
Message-ID: <87iqwr662p.fsf@macbook.be.48ers.dk>
References: <1211200476-21297-1-git-send-email-steve.glendinning@smsc.com>
	<1212403502-4604-1-git-send-email-steve.glendinning@smsc.com>
	<20080602155415.GA6192@solarflare.com>
	<48441B56.8080905@billgatliff.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	netdev@vger.kernel.org, Michael.Hennerich@analog.com,
	Enrik.Berkhan@ge.com, hennerich@blackfin.uclinux.org,
	ian.saturley@smsc.com, uclinux-dist-devel@blackfin.uclinux.org,
	catalin.marinas@arm.com, Bahadir Balban <Bahadir.Balban@arm.com>,
	Dustin Mcintire <dustin@sensoria.com>
To: Bill Gatliff <bgat@billgatliff.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.187]:25821 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751885AbYFBSci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 14:32:38 -0400
Received: by mu-out-0910.google.com with SMTP id w8so1190340mue.1
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2008 11:32:35 -0700 (PDT)
In-Reply-To: <48441B56.8080905@billgatliff.com> (Bill Gatliff's message of "Mon\, 02 Jun 2008 11\:09\:58 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Bill" == Bill Gatliff <bgat@billgatliff.com> writes:

 >>> +	/* Initialise tx packet using broadcast destination address */
 >>> +	for (i = 0; i < 6; i++)
 >>> +		pdata->loopback_tx_pkt[i] = (char)0xFF;
 >> 
 >> The cast to char is just noise.

 Bill> Not sure.  What about signed vs. unsigned?

No, because char can be both signed and unsigned. The driver should
rather do a memset(pdate->loopback_tx_pkt, 0xff, ETH_ALEN);

-- 
Bye, Peter Korsgaard
