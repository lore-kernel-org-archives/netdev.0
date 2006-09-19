From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: Fw: [PATCH] Remove powerpc specific parts of 3c509 driver
Date: Tue, 19 Sep 2006 14:44:25 -0500
Message-ID: <20060919194425.GO29167@austin.ibm.com>
References: <20060919145433.8fc7d478.sfr@canb.auug.org.au> <20060919184243.GL29167@austin.ibm.com> <45103C62.4080003@genesi-usa.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, akpm@osdl.org,
	ppc-dev <linuxppc-dev@ozlabs.org>, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:55986 "EHLO
	e35.co.us.ibm.com") by vger.kernel.org with ESMTP id S1751076AbWISTod
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 15:44:33 -0400
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8JJiVWD004492
	for <netdev@vger.kernel.org>; Tue, 19 Sep 2006 15:44:31 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8JJiV2S068960
	for <netdev@vger.kernel.org>; Tue, 19 Sep 2006 13:44:31 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8JJiU03004949
	for <netdev@vger.kernel.org>; Tue, 19 Sep 2006 13:44:31 -0600
To: Matt Sealey <matt@genesi-usa.com>
Content-Disposition: inline
In-Reply-To: <45103C62.4080003@genesi-usa.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 19, 2006 at 08:52:18PM +0200, Matt Sealey wrote:
[...]
> 
> Linas Vepstas wrote:
> >On Tue, Sep 19, 2006 at 02:54:33PM +1000, Stephen Rothwell wrote:
> >>On powerpc and ppc, insl_ns and insl are identical as are outsl_ns and
> >>outsl, so remove the conditional use of insl_ns and outsl_ns.
> >
> >The rest of this patch might indeed be correct, but the above comment 
> >bothers me. The "ns" versions of routines are supposed to be
> >non-byte-swapped versions of the insl/outsl routines (which would

Never mind. Silly me don't know my history. 

asm-powerpc/io.h clearly states

 * The *_ns versions below don't do byte-swapping.
 * Neither do the standard versions now, these are just here
 * for older code.

Seems that the byteswapping machanism was changed a while ago, 
and no longer handled in this way any more.

--linas
