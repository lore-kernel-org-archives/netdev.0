From: "George Spelvin" <linux-+7tBnqSOmQ59SlIZoIAWRdHuzzzSOjJt@public.gmane.org>
Subject: Re: Doing crypto in small stack buffers (bluetooth vs vmalloc-stack crash, etc)
Date: 29 Jun 2016 08:10:24 -0400
Message-ID: <20160629121024.2497.qmail@ns.sciencehorizons.net>
References: <20160629022049.GA23390@gondor.apana.org.au>
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, linux-+7tBnqSOmQ59SlIZoIAWRdHuzzzSOjJt@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160629022049.GA23390-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>> Also not mentioned in the documentation is that some algorithms *do*
>> have different implementations depending on key size.  SHA-2 is the
>> classic example.

> What do you mean by that? SHA has no keying at all.

In this case, the analagous property is hash size.  Sorry, I thought
that was so obvious I didn't need to say it.

Specifically, SHA2-256 (and -224) and SHA2-512 (and -384) are separate
algorithms with similar structures but deparate implementations.
