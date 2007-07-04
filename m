From: Patrick McHardy <kaber@trash.net>
Subject: Re: multicasting netlink messages to groups > 31 from userspace
Date: Wed, 04 Jul 2007 16:12:44 +0200
Message-ID: <468BAADC.4030203@trash.net>
References: <1183492286.4021.21.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Thomas Graf <tgraf@suug.ch>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38398 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759239AbXGDONu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2007 10:13:50 -0400
In-Reply-To: <1183492286.4021.21.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> Hey,
> 
> Looking through the code that uses NL_NONROOT_SEND I just realised that
> it's impossible to send multicast messages from userspace to multicast
> groups with IDs higher than 31. That's not really good given that
> everywhere else we handle multicast groups up to 2^32-1 :/


Why do you want to send to a multicast group from userspace?
