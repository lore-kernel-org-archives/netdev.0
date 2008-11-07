From: Yavor Goulishev <yavor@simplifymedia.com>
Subject: RE: [Patch] Establishing more than 64K outgoing TCP connections
Date: Fri, 7 Nov 2008 02:15:15 -0500
Message-ID: <241CE5A1B2AFFA4987A663380D74C0BB3FFD15887C@MBX73.ad2.softcom.biz>
References: <241CE5A1B2AFFA4987A663380D74C0BB3FFD158878@MBX73.ad2.softcom.biz>
	<20081106.222323.230548519.davem@davemloft.net>
	<241CE5A1B2AFFA4987A663380D74C0BB3FFD15887B@MBX73.ad2.softcom.biz>,<20081106.230405.25075428.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xsmtp12.mail2web.com ([168.144.250.177]:37282 "EHLO
	xsmtp12.mail2web.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929AbYKGHQ3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 02:16:29 -0500
In-Reply-To: <20081106.230405.25075428.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now I know why the kernel stays broken for so long.
Some people don't want to admit their errors and fix the issues.
Or at least explain them so that someone else can fix it for them.
I hope you work on something really important!

--Yavor
________________________________________
From: David Miller [davem@davemloft.net]
Sent: Thursday, November 06, 2008 11:04 PM
To: Yavor Goulishev
Cc: netdev@vger.kernel.org
Subject: Re: [Patch] Establishing more than 64K outgoing TCP connections

From: Yavor Goulishev <yavor@simplifymedia.com>
Date: Fri, 7 Nov 2008 01:57:34 -0500

> The current hash is only the port number.
> Not sure why you want linear access in a hash table though:
>   >  I'm asking for O(num_ports_bound / hash_table_size) access.
> What is this? Searching for unused port number?

Come back when you figure it out then.  I really don't have time to
explain it at the moment, perhaps someone else can.
