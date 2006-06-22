From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [1/5] [NET]: Merge TSO/UFO fields in sk_buff
Date: Wed, 21 Jun 2006 17:46:24 -0700
Message-ID: <1150937184.4069.4.camel@rh4>
References: <20060620090919.GA31613@gondor.apana.org.au>
 <20060620091050.GA31854@gondor.apana.org.au>
 <1150926495.3475.5.camel@rh4>
 <20060621232741.GA21559@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:45841 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1030475AbWFVBD1
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 21:03:27 -0400
To: "Herbert Xu" <herbert@gondor.apana.org.au>
In-Reply-To: <20060621232741.GA21559@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-06-22 at 09:27 +1000, Herbert Xu wrote:
> Hi Michael:
> 
> On Wed, Jun 21, 2006 at 02:48:15PM -0700, Michael Chan wrote:
> > 
> > We have some hardware that supports TSO and ECN.  Is something like the
> > patch below what you had in mind to support NETIF_F_TSO_ECN?  Or are you
> > thinking about something more generic that works with or without
> > hardware support?
> 
> Yeah I was thinking of something more generic because packets with CWR
> set should be rare.
> 
OK, if time permits, I'll cook up some patches to support generic TSO
ECN with or without hardware support.  Without hardware ECN, it will use
GSO to split up the packet with CWR.  Can we assume that all hardware
will handle ECE properly?

