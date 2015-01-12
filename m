From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] team: Remove dead code
Date: Mon, 12 Jan 2015 17:02:41 -0500 (EST)
Message-ID: <20150112.170241.2129572406940539468.davem@davemloft.net>
References: <20150112004351.GA8744@ubuntu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: ken@williamsclan.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54563 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752679AbbALWCn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 17:02:43 -0500
In-Reply-To: <20150112004351.GA8744@ubuntu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kenneth Williams <ken@williamsclan.us>
Date: Sun, 11 Jan 2015 16:43:54 -0800

> The deleted lines are called from a function which is called:
> 1) Only through __team_options_register via team_options_register and
> 2) Only during initialization / mode initialization when there are no
> ports attached.
> Therefore the ports list is guarenteed to be empty and this code will
> never be executed.
> 
> Signed-off-by: Kenneth Williams <ken@williamsclan.us>

Applied.
