From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 0/3] net: add device groups
Date: Mon, 10 Jan 2011 09:24:10 -0500
Message-ID: <1294669450.6063.319.camel@mojatatu>
References: <1294659524-22509-1-git-send-email-ddvlad@rosedu.org>
	 <1294666875.3583.6.camel@jlt3.sipsolutions.net>
	 <1294668021.6063.315.camel@mojatatu>
	 <1294668505.3583.9.camel@jlt3.sipsolutions.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vlad Dogaru <ddvlad@rosedu.org>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:45150 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753415Ab1AJOYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 09:24:11 -0500
Received: by vws16 with SMTP id 16so8070129vws.19
        for <netdev@vger.kernel.org>; Mon, 10 Jan 2011 06:24:10 -0800 (PST)
In-Reply-To: <1294668505.3583.9.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-01-10 at 15:08 +0100, Johannes Berg wrote:

> 
> Right, but where would you want to use it -- what's the use case right
> now? Your ppp example here makes me think the use case is some PPP
> endpoint server that has lots of these interfaces. 

That was just an example because someone mentioned PPP earlier.
Originally, this came from someone (Octavian?) trying to setup
a gazillion netdevs for testing purposes and then needing to
do "ip link ls dummy*" which causes a gazillion messages between
kernel and user space and all the filtering of what dummy* being
done in user space.

> It also means the
> grouping is entirely user-space controlled. In this case, the idea of
> automatically grouping based on the device structure seems pointless.

You still havent said what you want this grouping for. What is your
use case? ;->

cheers,
jamal

