From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] net: Add etun driver
Date: Tue, 10 Apr 2007 14:05:46 +0200
Message-ID: <461B7D9A.50902@trash.net>
References: <m1ps6g5229.fsf@ebiederm.dsl.xmission.com>	 <1176136628.8459.34.camel@johannes.berg> <461A70A5.8060607@trash.net>	 <20070409.114402.45491411.davem@davemloft.net>	 <m1mz1h1guo.fsf@ebiederm.dsl.xmission.com>  <461A9DF1.8080904@trash.net>	 <1176150557.8459.47.camel@johannes.berg>  <461AD517.2000906@trash.net>	 <1176184028.8459.58.camel@johannes.berg>  <461B4242.1040602@trash.net>	 <1176196734.8459.74.camel@johannes.berg>  <461B5E42.2030900@trash.net>	 <1176200879.8459.77.camel@johannes.berg>  <461B6B22.3090009@trash.net>	 <1176202930.8459.81.camel@johannes.berg>  <461B7060.8000407@trash.net> <1176204297.8459.86.camel@johannes.berg>
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
Received: from stinky.trash.net ([213.144.137.162]:59012 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965042AbXDJMGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2007 08:06:22 -0400
In-Reply-To: <1176204297.8459.86.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> Fair enough. Then the question however remains whether wireless should
> try to do all things it needs in one or try leveraging multiple things
> from other places. Thoughts?


I know too little about wireless to judge really this. My opinion is
that if it is possible to add and configure an interface (even if
only for simple cases) without knowledge about driver internals by
setting a few parameters, it would probably make sense to use
RTM_NEWLINK as well. If a userspace daemon or complex knowledge of
driver internals is needed, it probably should stay seperated.

So simply put: if I can implement support for
"ip wireless add dev wlan0 mode managed essid ... key ..."
in less than 100 lines and get a working connection afterwards, it
seems worth it.

