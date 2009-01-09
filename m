From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Make possible speeds known to ethtool
Date: Fri, 09 Jan 2009 00:05:13 -0500
Message-ID: <4966DB09.5040307@pobox.com>
References: <20090109041952.GA12087@gondor.apana.org.au> <20090108.210058.68468127.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, bhutchings@solarflare.com,
	rick.jones2@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34637 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750727AbZAIFFW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 00:05:22 -0500
In-Reply-To: <20090108.210058.68468127.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Fri, 9 Jan 2009 15:19:53 +1100
> 
>> Jeff Garzik <jgarzik@pobox.com> wrote:
>>> For generic net stack flags outside the driver's control, that can 
>>> easily be added to ethtool_{get,set}_flags() overriding or ignoring 
>>> whatever the driver may have done.
>> To use the flags interface as is, you'd have to go through every
>> single driver to get them to call ethtool_op_set_flags.  I'm sorry
>> but I'm sticking with the current interface.
> 
> Right, the flags thing is inappropriate without major reworking for
> Herbert's GRO case and therefore his choice was completely
> appropriate.

It took about ten minutes of coding to disprove this...

	Jeff



