From: Brent Cook <bcook@bpointsys.com>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Fri, 28 Apr 2006 15:46:28 -0500
Message-ID: <200604281546.29073.bcook@bpointsys.com>
References: <54AD0F12E08D1541B826BE97C98F99F143B0F3@NT-SJCA-0751.brcm.ad.broadcom.com> <20060428101833.2f0d6ae8@localhost.localdomain> <20060428.121052.39249337.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, caitlinb@broadcom.com, johnpol@2ka.mipt.ru,
	kelly@au1.ibm.com, rusty@rustcorp.com.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 70-253-197-251.ded.swbell.net ([70.253.197.251]:1294 "EHLO
	bpointsys.com") by vger.kernel.org with ESMTP id S1751450AbWD1Uqo
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 16:46:44 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060428.121052.39249337.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 28 April 2006 14:10, David S. Miller wrote:
> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Fri, 28 Apr 2006 10:18:33 -0700
>
> > Please just use existing AIO interface.
>
> I totally disagree, the existing AIO interface is garbage.
>
> We need new APIs to do this right, to get the ring buffer
> and the zero-copy'ness correct.
> -

Heh, like PF_RING? Just mmap a socket and read out some structures?
