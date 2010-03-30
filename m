From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH 2/7] flow: structurize flow cache
Date: Tue, 30 Mar 2010 15:02:42 +0300
Message-ID: <4BB1E862.8090302@iki.fi>
References: <1269871964-5412-1-git-send-email-timo.teras@iki.fi> <1269871964-5412-3-git-send-email-timo.teras@iki.fi> <20100330120104.GB5731@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:56388 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756408Ab0C3MCo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 08:02:44 -0400
Received: by ey-out-2122.google.com with SMTP id d26so1224771eyd.19
        for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 05:02:43 -0700 (PDT)
In-Reply-To: <20100330120104.GB5731@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Mon, Mar 29, 2010 at 05:12:39PM +0300, Timo Teras wrote:
>> Group all per-cpu data to one structure instead of having many
>> globals. Also prepare the internals so that we can have multiple
>> instances of the flow cache if needed.
> 
> Grouping everything together looks sane.  But adding the flow
> cache pointer to everything seems to be unnecessary.  Why would
> we need multiple flow caches?

Just a precaution since it doable cheaply.

If we want generic flow cache, we might want to have multiple
instance in future. It might also make sense to have per-net
flow cache.
