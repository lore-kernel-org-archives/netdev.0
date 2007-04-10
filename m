From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: Add etun driver
Date: Tue, 10 Apr 2007 00:08:48 -0600
Message-ID: <m1ejmszrpr.fsf@ebiederm.dsl.xmission.com>
References: <m1ps6g5229.fsf@ebiederm.dsl.xmission.com>
	<1176136628.8459.34.camel@johannes.berg> <461A70A5.8060607@trash.net>
	<20070409.114402.45491411.davem@davemloft.net>
	<m1mz1h1guo.fsf@ebiederm.dsl.xmission.com>
	<461A9DF1.8080904@trash.net> <1176150557.8459.47.camel@johannes.berg>
	<461AD517.2000906@trash.net> <1176184028.8459.58.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, greearb@candelatech.com,
	containers@lists.osdl.org, shemminger@linux-foundation.org,
	kuznet@ms2.inr.ac.ru, dim@openvz.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, jgarzik@pobox.com,
	David Miller <davem@davemloft.net>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:39627 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030384AbXDJGMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2007 02:12:19 -0400
In-Reply-To: <1176184028.8459.58.camel@johannes.berg> (Johannes Berg's message
	of "Tue, 10 Apr 2007 07:47:08 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg <johannes@sipsolutions.net> writes:

> Our virtual devices are always associated with a piece of hardware, and
> we really want them to be associated with that at all times, even when
> not UP. Everything else seems like a huge complication if only because
> then we can't have whoever will be responsible for the device allocate
> it's private space area.

How are you specifying which piece of hardware today?  By interface name?

What function do your virtual devices serve?

I'm trying to wrap my head around the model.

Eric
