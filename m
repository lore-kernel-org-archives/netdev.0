From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next 2/2] xfrm: Fix unaligned access in
 xfrm_notify_sa() for DELSA
Date: Wed, 21 Oct 2015 09:11:43 -0400
Message-ID: <20151021131143.GQ6948@oracle.com>
References: <20151021065704.GM7701@secunet.com>
 <20151021105442.GM6948@oracle.com>
 <20151021123628.GP6948@oracle.com>
 <20151021.062213.273447452472704627.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steffen.klassert@secunet.com, linux-crypto@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, dhowells@redhat.com,
	zohar@linux.vnet.ibm.com, David.Woodhouse@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151021.062213.273447452472704627.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (10/21/15 06:22), David Miller wrote:
> memcpy() _never_ works for avoiding unaligned accessed.
> 
> I repeat, no matter what you do, no matter what kinds of casts or
> fancy typing you use, memcpy() _never_ works for this purpose.
  :
> There is one and only one portable way to access unaligned data,
> and that is with the get_unaligned() and put_unaligned() helpers.

ok. I'll fix it up to use the *_unaligned functions and resend this 
out later today.

--Sowmini
