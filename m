From: jamal <hadi@cyberus.ca>
Subject: Re: patch2: del/get byid
Date: Wed, 27 Apr 2005 22:23:34 -0400
Message-ID: <1114655014.7663.61.camel@localhost.localdomain>
References: <1114654284.7663.50.camel@localhost.localdomain>
	 <20050428021426.GA23415@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050428021426.GA23415@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-28-04 at 12:14 +1000, Herbert Xu wrote:
> On Wed, Apr 27, 2005 at 10:11:24PM -0400, jamal wrote:
> > 
> > This is definetely a bug. It doesnt seem like get/del by index worked.
> > For some reason i thought i tested this before and it worked.
> 
> Why is this a bug? 

well, i think it is a bug that indices are being ignored by the kernel.
To demonstrate:
Add a rule with index 100;
now try to delete or get by index.

> Have you checked xfrm_gen_index?

I think that should be fine to use if the kernel specifies the index.

cheers,
jamal
