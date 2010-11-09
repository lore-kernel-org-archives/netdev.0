From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: alloc_netdev_mq() and multiqueues
Date: Tue, 09 Nov 2010 18:40:07 +0000
Message-ID: <1289328007.5567.24.camel@achroite.uk.solarflarecom.com>
References: <AANLkTi=8PrpAB+ARt-H3niNjnmQgHF1Ass345e95_pdq@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kevin Wilson <wkevils@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:36476 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753253Ab0KISkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 13:40:10 -0500
In-Reply-To: <AANLkTi=8PrpAB+ARt-H3niNjnmQgHF1Ass345e95_pdq@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-11-09 at 20:33 +0200, Kevin Wilson wrote:
> Hello,
> I have a short question about multiqueues  and I will appreciate if
> somebody can answer shortly in 2-3 sentences.
> When talking about multiqueues  I refer for example, to
> http://nfws.edenwall.com/nfws_userday/David-Miller_Linux-Multiqueue-Networking.pdf,
> alloc_netdev_mq() and friends.
> 
> 1) Does an ordinary network driver code can be adjusted to use
> multiqueues ? or do we need some
> special hardware feature ?

This feature is only useful if the hardware has multiple transmit
queues.

> 2) How can I know if a certain device support multiqueus?\

Read the hardware specs.

> 3) Can anybody name some network cards which support  multiqueues?

'git grep -l dev_mq drivers/net' will show you which drivers do.  I have
no knowledge beyond this of which hardware has multiple queues.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

