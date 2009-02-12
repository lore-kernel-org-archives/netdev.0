From: wli@movementarian.org
Subject: Re: [PATCH] Update jhash.h with the new version of Jenkins' hash
Date: Wed, 11 Feb 2009 19:12:23 -0500
Message-ID: <20090212001223.GA5757@movementarian.org>
References: <alpine.DEB.2.00.0902111107480.15665@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757330AbZBLAMj@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0902111107480.15665@blackhole.kfki.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 11, 2009 at 11:19:20AM +0100, Jozsef Kadlecsik wrote:
>  /* The golden ration: an arbitrary value */
> -#define JHASH_GOLDEN_RATIO	0x9e3779b9
> +#define JHASH_GOLDEN_RATIO	0xdeadbeef

The golden ratio is not an arbitrary value, nor is it a food ration.
It is (sqrt(5)+1)/2. and the original value of JHASH_GOLDEN_RATIO
approximated its reciprocal and/or fractional part in fixed point.

(double)0xdeadbeef/((unsigned long long)1 << 32) is a rather poor
approximation of (sqrt(5)-1)/2. If this value which is not the
golden ratio is arbitrary, calling it something different from
JHASH_GOLDEN_RATIO would surprise the code's readers much less.


-- wli
