From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Wed, 18 May 2005 09:11:57 +1000
Message-ID: <E1DYBED-0006wa-00@gondolin.me.apana.org.au>
References: <OF16EC9302.031C4230-ON88257004.007BA491-88257004.007C8D46@us.ibm.com>
Cc: rick.jones2@hp.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: dlstevens@us.ibm.com (David Stevens)
In-Reply-To: <OF16EC9302.031C4230-ON88257004.007BA491-88257004.007C8D46@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David Stevens <dlstevens@us.ibm.com> wrote:
> 
>        This assumes that you have a per-destination IP ID. If it's 
> per-route,
> you can send 1 packet to host A, 65534 to host B through the same route, 
> and
> 1 to host A-- wrap on the next received packet, as far as host A is 
> concerned.
> (even sooner, if it's using randomized ID's or a bigger-than-1 increment).

Such systems would be violating the spirit of RFC791 which says:

    The identification field is used to distinguish the fragments of one
    datagram from those of another.  The originating protocol module of
    an internet datagram sets the identification field to a value that
    must be unique for that source-destination pair and protocol for the
    time the datagram will be active in the internet system.

Are you aware of any extant systems that do this?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
