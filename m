From: David Miller <davem@davemloft.net>
Subject: Re: [RFC patch net-next] ipv4: use bcast as dst address in case
 IFF_NOARP is set
Date: Tue, 08 Jan 2013 14:33:13 -0800 (PST)
Message-ID: <20130108.143313.1895311523435309641.davem@davemloft.net>
References: <1357650162-5554-1-git-send-email-jiri@resnulli.us>
	<7abb4995-17a4-49ca-b0a7-41af6ff763e1@tahiti.vyatta.com>
	<20130108174538.GC1621@minipsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen.hemminger@vyatta.com, edumazet@google.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org, pavlix@pavlix.net
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33805 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755431Ab3AHWdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 17:33:14 -0500
In-Reply-To: <20130108174538.GC1621@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 8 Jan 2013 18:45:38 +0100

> I believe this may have been intentional, but what sense does it have to
> use dev_addr as destination address? That is what I do not understand.

It's the only address we know isn't someone else's and is not broadcast.
