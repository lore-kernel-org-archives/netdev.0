From: Tadeusz Struk <tadeusz.struk@intel.com>
Subject: Re: [PATCH v3 net-next 0/3] Add support for async socket operations
Date: Mon, 23 Mar 2015 14:13:21 -0700
Message-ID: <551081F1.9090303@intel.com>
References: <20150319193118.11500.10463.stgit@tstruk-mobl1> <20150323.164221.1726829049738525120.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-aio@kvack.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, ying.xue@windriver.com, bcrl@kvack.org,
	viro@ZenIV.linux.org.uk, linux-fsdevel@vger.kernel.org, hch@lst.de,
	linux-crypto@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20150323.164221.1726829049738525120.davem@davemloft.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/23/2015 01:42 PM, David Miller wrote:
> From: Tadeusz Struk <tadeusz.struk@intel.com>
> Date: Thu, 19 Mar 2015 12:31:19 -0700
> 
>> After the iocb parameter has been removed from sendmsg() and recvmsg() ops
>> the socket layer, and the network stack no longer support async operations.
>> This patch set adds support for asynchronous operations on sockets back.
>>
>> Changes in v3:
>> * As sugested by Al Viro instead of adding new functions aio_sendmsg
>>   and aio_recvmsg, added a ptr to iocb into the kernel-side msghdr structure.
>>   This way no change to aio.c is required.
>>
>> Changes in v2:
>> * removed redundant total_size param from aio_sendmsg and aio_recvmsg functions
> 
> Series applied to net-next.
> 

Thanks Dave!

Herbert, is it possible to pull it to cryptodev?

