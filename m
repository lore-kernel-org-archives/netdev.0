From: David Ford <david@blue-labs.org>
Subject: Re: NULL pointer dereference at	2.6.32-rc8:net/ipv4/ip_fragment.c:566
Date: Mon, 30 Nov 2009 23:57:07 -0500
Message-ID: <4B14A223.90203@blue-labs.org>
References: <20091201043759.GA22655@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from blue-labs.org ([72.34.249.230]:47932 "EHLO blue-labs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753210AbZLAE5J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Nov 2009 23:57:09 -0500
In-Reply-To: <20091201043759.GA22655@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

thank you for your reply. my patch has already gone thru dave miller's
git, so i expect it'll show up in -rc9.

cheers,
-david

Herbert Xu wrote:
> David Ford <firefighterblu3@gmail.com> wrote:
>   
>> hmm.  that shows a patch of code which is just prior to ip_defrag(), i.e.:
>>
>>    565 out_fail:
>>    566         IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_REASMFAILS);
>>     
>
> Looks like a namespace problem.
>
> Please open a bug report on bugzilla.kernel.org to ensure that
> this is tracked.
>
> Cheers,
>   

