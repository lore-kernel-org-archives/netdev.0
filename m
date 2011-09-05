From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] bridge: leave carrier on for empty bridge
Date: Mon, 5 Sep 2011 10:57:35 -0700
Message-ID: <20110905105735.1b912715@nehalam.ftrdhcpuser.net>
References: <20110902172220.830228928@vyatta.com>
	<20110902172247.396753508@vyatta.com>
	<4E614CF7.7030700@gmail.com>
	<20110902151100.327af0bf@nehalam.ftrdhcpuser.net>
	<4E6272BC.4020707@gmail.com>
	<20110903211438.2a43d2f2@nehalam.ftrdhcpuser.net>
	<4E632A2E.5040805@gmail.com>
	<20110904093634.685d7c56@nehalam.ftrdhcpuser.net>
	<4E65046E.1020005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Nicolas de =?ISO-8859-1?B?UGVzbG/8YW4=?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36447 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751880Ab1IER5Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Sep 2011 13:57:24 -0400
In-Reply-To: <4E65046E.1020005@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The root cause of the problem is applications that don't deal with unresolved
IPv6 addresses. I already had to solve this in our distribution for NTP in a
not bridge related problem. It is better to fix the applications to understand
IPv6 address semantics than to try and force bridge to behave in a way that
is friendly to these applications.

The earlier mail said it is a problem with dnsmasq and radvd. Let's work on understanding
if they need to be updated before jumping in with hacks to the bridge code.
