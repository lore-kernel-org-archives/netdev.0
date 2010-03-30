From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH 4/7] flow: delayed deletion of flow cache entries
Date: Tue, 30 Mar 2010 15:32:58 +0300
Message-ID: <4BB1EF7A.7030407@iki.fi>
References: <1269871964-5412-1-git-send-email-timo.teras@iki.fi> <1269871964-5412-5-git-send-email-timo.teras@iki.fi> <20100330122217.GF5731@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:11044 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753236Ab0C3MdC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 08:33:02 -0400
Received: by ey-out-2122.google.com with SMTP id d26so1229703eyd.19
        for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 05:33:01 -0700 (PDT)
In-Reply-To: <20100330122217.GF5731@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Mon, Mar 29, 2010 at 05:12:41PM +0300, Timo Teras wrote:
>> Speed up lookups by freeing flow cache entries later. This is also in
>> preparation to have virtual entry destructor that might do more
>> work.
> 
> So how does this speed up lookups exactly?

If flow cache regeneration or shrinking is triggered in lookup,
it would previously free it in place. Now that is deferred. But
yes, it's more useful after the next patches that call the
virtual destructor. Should have explained this better.

Like said in the general description, patches 4-7 go together
and still have some problem cases. But should show where I'm
trying to go.

I'd be interested hear if the idea of patches 4-7 is good
or we could things somehow better.
