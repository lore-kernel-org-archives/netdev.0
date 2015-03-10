From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next v2 0/2] net: Remove iocb argument from sendmsg
 and recvmsg
Date: Tue, 10 Mar 2015 16:58:43 +1100
Message-ID: <20150310055843.GA15054@gondor.apana.org.au>
References: <20150302.130656.1723071239422371932.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ying.xue@windriver.com, viro@zeniv.linux.org.uk, hch@lst.de,
	netdev@vger.kernel.org, erik.hugne@ericsson.com,
	jon.maloy@ericsson.com, Tadeusz Struk <tadeusz.struk@intel.com>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150302.130656.1723071239422371932.davem@davemloft.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
> From: Ying Xue <ying.xue@windriver.com>
> Date: Mon, 2 Mar 2015 15:37:46 +0800
> 
>> Currently there is only one user - TIPC whose sendmsg() instances
>> using iocb argument. Meanwhile, there is no user using iocb argument
>> in its recvmsg() instance. Therefore, if we eliminate the werid usage
>> of iobc argument from TIPC, the iocb argument can be removed from
>> all sendmsg() and recvmsg() instances of the whole networking stack.
>> 
>> Reference:
>> https://patchwork.ozlabs.org/patch/433960/
>> 
>> Changes:
>> 
>> v2:
>>  * Fix compile errors of DCCP module pointed by David
> 
> Series applied, thanks.

This totally breaks Tadeusz Struk's attempt at making an AIO
interface for algif_skcipher:

	https://patchwork.kernel.org/patch/5971491/

Now granted nothing in the network stack ever supported AIO so
maybe this is a bad idea anyway.  But I guess it's a good time
and place to discuss what alternatives are available for Tadeus
to export his crypto hardware using an asynchronous interface
to user-space?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
