From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] net: Add etun driver
Date: Tue, 10 Apr 2007 09:52:34 +0200
Message-ID: <461B4242.1040602@trash.net>
References: <m1ps6g5229.fsf@ebiederm.dsl.xmission.com>	 <1176136628.8459.34.camel@johannes.berg> <461A70A5.8060607@trash.net>	 <20070409.114402.45491411.davem@davemloft.net>	 <m1mz1h1guo.fsf@ebiederm.dsl.xmission.com>  <461A9DF1.8080904@trash.net>	 <1176150557.8459.47.camel@johannes.berg>  <461AD517.2000906@trash.net> <1176184028.8459.58.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	dim@openvz.org, netdev@vger.kernel.org, jgarzik@pobox.com,
	containers@lists.osdl.org, kuznet@ms2.inr.ac.ru,
	shemminger@linux-foundation.org, greearb@candelatech.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54230 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753100AbXDJHws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2007 03:52:48 -0400
In-Reply-To: <1176184028.8459.58.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> Our virtual devices are always associated with a piece of hardware, and
> we really want them to be associated with that at all times, even when
> not UP. Everything else seems like a huge complication if only because
> then we can't have whoever will be responsible for the device allocate
> it's private space area.


Shouldn't be a problem either. Creating the device atomically also
prevents that anything else is setting them UP before they're fully
configured.
