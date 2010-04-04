From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH 1/4] flow: virtualize flow cache entry methods
Date: Sun, 04 Apr 2010 15:09:59 +0300
Message-ID: <4BB88197.5020400@iki.fi>
References: <1270126340-30181-1-git-send-email-timo.teras@iki.fi> <1270126340-30181-2-git-send-email-timo.teras@iki.fi> <20100404104230.GA10368@gondor.apana.org.au> <4BB86EE8.5090203@iki.fi> <20100404110014.GA10864@gondor.apana.org.au> <4BB872CF.2030202@iki.fi> <20100404112636.GA11061@gondor.apana.org.au> <20100404113142.GA11124@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:33361 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752755Ab0DDMKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Apr 2010 08:10:03 -0400
Received: by ewy20 with SMTP id 20so873397ewy.1
        for <netdev@vger.kernel.org>; Sun, 04 Apr 2010 05:10:01 -0700 (PDT)
In-Reply-To: <20100404113142.GA11124@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Sun, Apr 04, 2010 at 07:26:36PM +0800, Herbert Xu wrote:
>> Fine, move key into flow_cache_entry but the rest should still
>> work, no?
>
> OK this doesn't work either as we still have NULL objects for
> now.  But I still think even if the ops pointer is the only
> member in flow_cache_object, it looks better than returning the
> nested ops pointer directly from flow_cache_lookup.

Yes, it'll look better. I'll wrap the pointer in a struct.

Ok, so far it's:
 - constify ops
 - indentation fixes for flow.c struct's with pointer members
 - wrap ops* in a struct* to avoid ops**

Will fix and resend refreshed patches tomorrow.

Thanks.
