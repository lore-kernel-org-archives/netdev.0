From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH] xfrm: fix hmac(sha256) truncation length
Date: Fri, 09 Mar 2012 08:41:10 -0500
Message-ID: <4F5A0876.3060408@redhat.com>
References: <1331151157-19149-1-git-send-email-jarod@redhat.com> <20120308003741.GA14995@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Paul Wouters <pwouters@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Willi <martin@strongswan.org>, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20120308003741.GA14995@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Wed, Mar 07, 2012 at 03:12:37PM -0500, Jarod Wilson wrote:
>> Commit bc74b0c8af17458ecae77f725e507ab5fd100105 added proper hmac sha384
>> and sha512 variants with truncation lengths of 192 and 256 respectively,
>> per RFC4868:
>
> No, it was done deliberately to maintain backwards compatibility.
> Userspace should set the truncbits explicitly from now on.

Okay, I suspected that might be the case. No plans to ever invert that, 
so that userspace has to explicitly set the shorter truncbits for 
backwards compat?

-- 
Jarod Wilson
jarod@redhat.com.
