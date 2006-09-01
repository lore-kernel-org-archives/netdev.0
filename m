From: jamal <hadi@cyberus.ca>
Subject: Re: [GENL]: Provide more information to userspace about registered
	genl families
Date: Fri, 01 Sep 2006 08:22:11 -0400
Message-ID: <1157113331.5057.67.camel@jzny2>
References: <20060831212129.GF3470@postel.suug.ch>
	 <1157060812.5297.51.camel@jzny2>  <1157093281.2878.19.camel@ux156>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:36276 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1751141AbWIAMWR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 08:22:17 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1GJ82L-0000U0-9L
	for netdev@vger.kernel.org; Fri, 01 Sep 2006 08:22:17 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1157093281.2878.19.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-01-09 at 08:48 +0200, Johannes Berg wrote:

> What I'd personally like to see for nl80211 if we go there is an actual
> filter callback, then I could completely avoid the command I have in
> there for getting a command list for a given interface, and just filter
> out those commands that some interface doesn't support.

Seems you may be talking about capabilities more than filtering?
Sorry, I havent had time to look at that code (is it in Daves tree?); if
i understand you correctly - you have a superset of commands, and some
users of those commands can only implement a subset?

cheers,
jamal

