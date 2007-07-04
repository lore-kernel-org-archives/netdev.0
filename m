From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: multicasting netlink messages to groups > 31 from userspace
Date: Wed, 4 Jul 2007 16:04:40 +0400
Message-ID: <20070704120440.GB6336@2ka.mipt.ru>
References: <1183492286.4021.21.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Patrick McHardy <kaber@trash.net>, Thomas Graf <tgraf@suug.ch>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:53541 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761486AbXGDMFI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jul 2007 08:05:08 -0400
Content-Disposition: inline
In-Reply-To: <1183492286.4021.21.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 03, 2007 at 09:51:25PM +0200, Johannes Berg (johannes@sipsolutions.net) wrote:
> Does anybody have any better ideas?

Hi Johannes.

Why don't you want to reserve a set of bits in group number, which means 
'allow to work with unpriveledged users', that bits should not cross existing 
users (hardcoded in various files in kernel), all new code can use that
groups.
This effectively limits number of groups, but hell, number of them was so
small just a year or two ago and no one complained (although that was a
reason for connector and gennetlink to appear).

I've read a thread about problems limiting 2^32 group space, while no
user has even more than 10...

> johannes



-- 
	Evgeniy Polyakov
