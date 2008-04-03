From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Three TCP/IP warnings in 2.6.25-rc7-git1
Date: Thu, 3 Apr 2008 16:11:13 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804031517270.21524@wrl-59.cs.helsinki.fi>
References: <47F15200.3060706@linux.intel.com> <47F46945.40500@linux.intel.com>
 <20080402.222846.92587028.davem@davemloft.net> <20080403055435.M45441@visp.net.lb>
 <Pine.LNX.4.64.0804030934040.10964@wrl-59.cs.helsinki.fi>
 <20080403121337.M42798@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, arjan@linux.intel.com,
	Netdev <netdev@vger.kernel.org>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48060 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754443AbYDCNLP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 09:11:15 -0400
In-Reply-To: <20080403121337.M42798@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 3 Apr 2008, Denys Fedoryshchenko wrote:

> I will apply this patch tonight. And will send all output most probably at
> morning. At the current moment probably expensive things i cannot try, because
> it is loaded proxy. But after 2-3 days when i will be a bit free - we can try
> to do them, maybe it will withstand.

IMHO there's no need to take risks currently, lets see what the debug 
info reveals, it might even show that some (maybe even all because 
sacktag bugs haven't been seen for a while) fackets_out problems occur 
for non-SACK TCP, which won't be a problem at all and that one could 
safely be silenced if so desired...


-- 
 i.
