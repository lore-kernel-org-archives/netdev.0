From: Alex Gartrell <agartrell@fb.com>
Subject: Re: [RFC PATCH net-next] tun: support retrieving multiple packets
 in a single read with IFF_MULTI_READ
Date: Mon, 22 Dec 2014 15:39:05 -0800
Message-ID: <5498AB99.6060900@fb.com>
References: <20141222120957.GA21319@gondor.apana.org.au> <54987C9F.5070103@fb.com> <20141222223436.GA25970@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <jasonwang@redhat.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<mst@redhat.com>, <herbert@gondor.apena.org.au>,
	<kernel-team@fb.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141222223436.GA25970@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey Herbert,

On 12/22/2014 02:34 PM, Herbert Xu wrote:
> On Mon, Dec 22, 2014 at 12:18:39PM -0800, Alex Gartrell wrote:
>>
>> While fully aware that this makes me look like an idiot, I have to
>> admit that I've tried and failed to figure out how to get a socket
>> fd out of the tun device.
>
> Well right now the socket is only used within the kernel by
> vhost so it's not exported to user-space.  If we were to use
> recvmmsg obviously we'd create a new interface based on sockets
> for tun and expose the existing socket through that.

Ah, that explains it then.  I was afraid I was just going insane :)

> The current file-based tun interface was never designed to be
> a high-performance interface.  So let's take this opportunity
> and create a new interface (but still using the same underlying
> code since whatever you create should be easily applicable to
> the existing kernel user vhost).

Sounds good to me. I'll get a patch turned around soon.

Thanks,
-- 
Alex Gartrell <agartrell@fb.com>
