From: Moni Shoua <monis@voltaire.com>
Subject: Re: bonding / 2.6.24-rc1 issues
Date: Wed, 07 Nov 2007 16:52:23 +0200
Message-ID: <4731D127.9060301@voltaire.com>
References: <4731C2DE.4000701@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>, Roland Dreier <rolandd@cisco.com>,
	netdev@vger.kernel.org, Moni Levy <monil@voltaire.com>
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:22166 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758624AbXKGOw0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 09:52:26 -0500
In-Reply-To: <4731C2DE.4000701@voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Or Gerlitz wrote:
> Jay, Moni
> 
> I did some tests with 2.6.24-rc1 and the first patch to bonding that Jay
> sent last night to netdev. Basic operation and fail over work fine.
> However, I see some crashes which are somehow related to destroying the
> bond when the slaves are ipoib ones, I don't see similar crashes when
> enslaving ethernet devices (Broadcom Corporation NetXtreme BCM5704
> Gigabit Ethernet (rev 03)), my compressed dot config is attached.
> 
> The first type of oops is when I just do modprobe -r bonding after
> enslavement of the ipoib devices:
> 
> 
> the second type of oops is when I modprobe -r ib_ipoib after
> enslavement. I was not able to test this one with ethernet as the tg3
> code is built into my kernel

I couldn't reproduce the first oops. However, after applying Jay's
fixes for 2.6.24-rc1 I managed to reproduce the second oops.
I will try to look into it.


