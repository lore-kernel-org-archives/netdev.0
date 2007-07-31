From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH RFC]: napi_struct V4
Date: Mon, 30 Jul 2007 19:01:55 -0700
Message-ID: <adamyxdpbzg.fsf@cisco.com>
References: <ada1wesy2eh.fsf@cisco.com>
	<20070728.223206.112621083.davem@davemloft.net>
	<ada7ioiszk7.fsf@cisco.com>
	<20070730.154854.07455239.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com, hadi@cyberus.ca, rusty@rustcorp.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1-in.cisco.com ([171.71.176.70]:25442 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753629AbXGaCCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 22:02:00 -0400
In-Reply-To: <20070730.154854.07455239.davem@davemloft.net> (David Miller's message of "Mon, 30 Jul 2007 15:48:54 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > It is not a feature of these changes.

 > These races exist in the current code, it is a bug fix.

Not sure I follow.  What is the race in the current code?  Are you
saying that netif_rx_reschedule() itself is racy?  Otherwise the code
in ipoib looks OK to me.

 - R.
