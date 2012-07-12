From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/3] team: couple of patches
Date: Thu, 12 Jul 2012 08:14:43 -0700 (PDT)
Message-ID: <20120712.081443.1373285885474644661.davem@davemloft.net>
References: <1342020844-3547-1-git-send-email-jpirko@redhat.com>
	<20120712.081124.1207448876900334978.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57411 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932679Ab2GLPOo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 11:14:44 -0400
In-Reply-To: <20120712.081124.1207448876900334978.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 12 Jul 2012 08:11:24 -0700 (PDT)

> From: Jiri Pirko <jpirko@redhat.com>
> Date: Wed, 11 Jul 2012 17:34:01 +0200
> 
>> Jiri Pirko (3):
>>   team: use function team_port_txable() for determing enabled and up
>>     port
>>   team: add broadcast mode
>>   team: make team_port_enabled() and team_port_txable() static inline
> 
> All applied, thanks.

Jiri, btw, any chance I can convince you to remove the EXPERIMENTAL
Kconfig dependency?

Code I've written and checked in myself over the past few days is
several orders of magnitude more experimental than the team driver
is :-)
