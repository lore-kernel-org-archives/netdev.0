From: "Bruce Rogers" <brogers@novell.com>
Subject: Re: [PATCH] KVM: add schedule check to napi_enable call
Date: Mon, 14 Jun 2010 14:44:17 -0600
Message-ID: <4C16404102000048000980A8@sinclair.provo.novell.com>
References: <4C07F8FF0200004800097554@sinclair.provo.novell.com>
 <20100606094048.GA1979@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <rusty@rustcorp.com.au>, <netdev@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20100606094048.GA1979@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 >>> On 6/6/2010 at 03:40 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote: 
> Bruce Rogers <brogers@novell.com> wrote:
>> Please consider this patch for the 2.6.32, 2.6.33, and 2.6.34 stable trees 
> as well as current development trees. (I've only tested on 2.6.32 however)
>> 
>>    virtio_net: Add schedule check to napi_enable call
>>    Under harsh testing conditions, including low memory, the guest would
>>    stop receiving packets. With this patch applied we no longer see any
>>    problems in the driver while performing these tests for extended periods
>>    of time.
>> 
>>    Make sure napi is scheduled subsequent to each napi_enable.
>> 
>>    Signed-off-by: Bruce Rogers <brogers@novell.com>
>>    Signed-off-by: Olaf Kirch <okir@suse.de>
>>    Acked-by: Rusty Russell <rusty@rustcorp.com.au>
>>    Cc: stable@kernel.org
> 
> Looks good to me.
> 
> Thanks!


Thanks for the review.

We are hoping to get this into our 2.6.32 based sle11 sp1 maintenance update. Are there any concerns with this patch?

Bruce

