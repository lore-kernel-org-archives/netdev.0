From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH 02/34]bnx2x: Barriers for the compiler
Date: Thu, 15 Jan 2009 11:50:57 +0200
Message-ID: <1232013057.4971.8.camel@lb-tlvb-eliezer>
References: <1231951364.11301.123.camel@lb-tlvb-eliezer>
 <20090114.131356.63668949.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2140 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754926AbZAOJvq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2009 04:51:46 -0500
In-Reply-To: <20090114.131356.63668949.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-01-14 at 13:13 -0800, David Miller wrote:
> From: "Eilon Greenstein" <eilong@broadcom.com>
> Date: Wed, 14 Jan 2009 18:42:44 +0200
> 
> > To make sure no swapping are made by the compiler, changed HAS_WORK to inline
> > functions and added all the necessary barriers
> > 
> > Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> 
> Don't you need cpu memory barriers too?  What if the cpu reorders what
> you're trying to order using just a compiler barrier?
> 
The CPU memory barriers are in place (actually, they needed some fixing,
but that was in another patch) - this one is just for the compiler and
after reviewing it again now, I still believe that it is sufficient. I
need the current executing CPU to take the right decision based on what
it currently knows - synchronization between CPUs and HW is using CPU
memory barrier.

IMHO this patch is correct.

Eilon


