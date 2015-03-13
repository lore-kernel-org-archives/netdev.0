From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] switchdev: support stp updates on
 stacked netdevices
Date: Fri, 13 Mar 2015 12:31:56 -0400 (EDT)
Message-ID: <20150313.123156.2118585119289960334.davem@davemloft.net>
References: <1426206598-29410-1-git-send-email-roopa@cumulusnetworks.com>
	<20150313.001007.65274068513753002.davem@davemloft.net>
	<5502E544.7030003@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51152 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753188AbbCMQb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 12:31:58 -0400
In-Reply-To: <5502E544.7030003@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roopa <roopa@cumulusnetworks.com>
Date: Fri, 13 Mar 2015 06:25:24 -0700

> David, if you mean not touch bond and team but have the switchdev
> api do it transparently, yes, i had it that way initially.  And i do
> liked it that way as well. But the feedback i received (during the
> initial introduction of this for setlink/dellink) was to make it
> explicit for each master.

I think the concern is that we only want to do this for devices
for which it is safe to "traverse" down like this.

But frankly I cannot think of any layered device where we would
not want to do this.

Let's go back to the simple scheme where we unconditionally traverse
and if we hit a problem case we'll figure out how to deal with it
then, ok?
