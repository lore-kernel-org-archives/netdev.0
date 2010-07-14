From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch] netfilter: default to NF_DROP in sip_help_tcp()
Date: Wed, 14 Jul 2010 21:38:48 +0900
Message-ID: <20100714123846.GA16045@verge.net.au>
References: <20100710031604.GA26990@verge.net.au>
 <4C3DAC25.3050401@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:37069 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753588Ab0GNMix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 08:38:53 -0400
Content-Disposition: inline
In-Reply-To: <4C3DAC25.3050401@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 14, 2010 at 02:23:01PM +0200, Patrick McHardy wrote:
> On 10.07.2010 05:16, Simon Horman wrote:
> > I initially noticed this because of the compiler warning below, but it does
> > seem to be a valid concern in the case where ct_sip_get_header() returns 0
> > in the first iteration of the while loop.
> > 
> > net/netfilter/nf_conntrack_sip.c: In function 'sip_help_tcp':
> > net/netfilter/nf_conntrack_sip.c:1379: warning: 'ret' may be used uninitialized in this function
> 
> Thanks Simon. I've applied the patch, but changed NF_DROP to
> NF_ACCEPT since we should avoid dropping packets with unknown
> contents (not SIP) if possible.

Thanks, to be honest I was a bit unsure of what policy was best.

