From: Ming Liu <liu.ming50@gmail.com>
Subject: Re: HELP: IPsec reordering issue
Date: Thu, 31 Jul 2014 14:27:04 +0800
Message-ID: <53D9E1B8.3070607@gmail.com>
References: <53D9B2EE.5040002@gmail.com> <20140731062321.GA2957@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, davem@davemloft.net,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	Xue Ying <ying.xue@windriver.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20140731062321.GA2957@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/31/2014 02:23 PM, Herbert Xu wrote:
> On Thu, Jul 31, 2014 at 11:07:26AM +0800, Ming Liu wrote:
>> And we've figure out a patch as the attached, the basic idea is just
>> queue the packets if "irq_fpu_usable()" is not usable or if there
>> are already few packets queued for decryption. Else decrypt the
>> packets.
> Yes your description makes sense and I will review your patch
> for inclusion.
Thanks, Herbert!

//Ming Liu
>
> Thanks,
