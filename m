From: Chris Stromsoe <cbs@cts.ucla.edu>
Subject: Re: WARNING: at net/core/dev.c:1505 skb_gso_segment+0x6e/0x156()
Date: Mon, 2 Mar 2009 12:32:32 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0903021211120.28055@potato.cts.ucla.edu>
References: <20090302041542.GA15961@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out-31.smtp.ucla.edu ([169.232.48.161]:38000 "EHLO
	out-31.smtp.ucla.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755283AbZCBUii (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 15:38:38 -0500
In-Reply-To: <20090302041542.GA15961@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2 Mar 2009, Herbert Xu wrote:

> Chris Stromsoe <cbs@cts.ucla.edu> wrote:
>> I'm seeing these show up pretty regularly on several Dell 1750s running 
>> 2.6.27.19, with both tg3 ports bonded together in an active-backup 
>> configuration.
>
> Please try to reproduce this under 2.6.28-rcX where it'll print more 
> details about what went wrong.  I'd suspect that something went amiss 
> with the features computation on the bonding device.

I am not seeing the warnings with 2.6.28.7 on the same hardware.  Did you 
want me to try with one of the 2.6..28-rcX kernels, or was that a typo for 
2.6.29-rcX ?


-Chris
