From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] tcp: Increase the initial congestion window to 10.
Date: Thu, 03 Feb 2011 15:26:03 +0100
Message-ID: <1b6ae8e6f5a57cf75b434f55911fd09b@localhost>
References: <20110202.170750.229739784.davem@davemloft.net>
 <47859e9273bb0c1b2c32fc1adfa450ee@localhost>
 <AANLkTinEXYXeZs1=wVQRAPDQ53YY0ne9NgCZN3x1hbaA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<dccp@vger.kernel.org>, <therbert@google.com>
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:41990 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751727Ab1BCO0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 09:26:05 -0500
In-Reply-To: <AANLkTinEXYXeZs1=wVQRAPDQ53YY0ne9NgCZN3x1hbaA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 3 Feb 2011 09:17:14 -0500, John Heffner wrote:



> There's already a per-route tunable, right (RTAX_INITCWND)?



Yes, __u32 cwnd = (dst ? dst_metric(dst, RTAX_INITCWND) : 0);



I was a little bit nervous ... ;)



HGN
