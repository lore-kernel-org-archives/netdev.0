From: David Miller <davem@davemloft.net>
Subject: Re: Question on device events and unregister_netdev.
Date: Tue, 11 Jul 2006 16:43:31 -0700 (PDT)
Message-ID: <20060711.164331.122338629.davem@davemloft.net>
References: <44B433DD.8070100@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:19150
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932254AbWGKXmn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 19:42:43 -0400
To: greearb@candelatech.com
In-Reply-To: <44B433DD.8070100@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Tue, 11 Jul 2006 16:27:25 -0700

> So, the question is: Should I be calling unregister_netdev from the
> notifier callback?

Not really, as you saw it can be deadlock prone.

One idea is to run the unregister asynchronously via a workqueue.
That should be able to get you out of the deadlock.
