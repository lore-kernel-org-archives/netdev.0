From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] core: Don't attempt to load the "" driver.
Date: Tue, 02 Sep 2014 14:03:07 -0700 (PDT)
Message-ID: <20140902.140307.925789601609547435.davem@davemloft.net>
References: <063D6719AE5E284EB5DD2968C1650D6D174856B9@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58606 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755161AbaIBVDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 17:03:08 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D174856B9@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM>
Date: Tue, 2 Sep 2014 13:48:39 +0000

> Requests like 'ifconfig ""' cause dev_load(net, "") be called, since
> request_module("") return 0 (success) this generates the error message:
> "Loading kernel module for a network device with CAP_SYS_MODULE (deprecated).  Use CAP_NET_ADMIN and alias netdev- instead."
> 
> Since dev_load() doesn't have to work, just ignore such names.

Patch submissions require a signoff.

Please freshly resubmit this with an appropriate signoff, thanks.
