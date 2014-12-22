From: Alex Gartrell <agartrell@fb.com>
Subject: Re: [RFC PATCH net-next] tun: support retrieving multiple packets
 in a single read with IFF_MULTI_READ
Date: Mon, 22 Dec 2014 12:18:39 -0800
Message-ID: <54987C9F.5070103@fb.com>
References: <20141222120957.GA21319@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <jasonwang@redhat.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<mst@redhat.com>, <herbert@gondor.apena.org.au>,
	<kernel-team@fb.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141222120957.GA21319@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey Herbert,

Thanks for getting back to me

On 12/22/14 4:09 AM, Herbert Xu wrote:
> As tun already has a socket interface can we do this through
> recvmmsg?

This just presents an easier interface (IMHO) for accomplishing that. 
And I say easier because I was unable how to figure out the recvmmsg way 
to do it.

While fully aware that this makes me look like an idiot, I have to admit 
that I've tried and failed to figure out how to get a socket fd out of 
the tun device.

The regular fd doesn't work (which is obvious when you look at the 
implementation sock_from_file), there's a tun_get_socket function but 
it's only referenced by a single file, and none of the ioctl's jump out 
at me as doing anything to enable this behavior.  Additionally, 
tuntap.txt makes no mention of sockets specifically.

FWIW, I don't feel strongly that IFF_MULTI_READ is the right way to do 
this either.

Thanks,
-- 
Alex Gartrell <agartrell@fb.com>
