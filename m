From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH RFC v3 0/12] vti4: prepare namespace and interfamily
 support.
Date: Fri, 14 Feb 2014 08:48:01 +0100
Message-ID: <20140214074801.GD3438@secunet.com>
References: <1390818577-19589-1-git-send-email-steffen.klassert@secunet.com>
 <52E8DE2C.7060706@6wind.com>
 <20140130095610.GR31491@secunet.com>
 <52F0C962.5080804@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Saurabh Mohan <saurabh.mohan@vyatta.com>
To: Christophe Gouault <christophe.gouault@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:38427 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751578AbaBNHsF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 02:48:05 -0500
Content-Disposition: inline
In-Reply-To: <52F0C962.5080804@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 04, 2014 at 12:05:06PM +0100, Christophe Gouault wrote:
> 
> Hi Steffen, and thank you for the patch.
> 
> I tested it within a single netns, then with cross-netns.

Thaks a lot for testing!

> 
> Unfortunately, the inbound/forward policy checks do not take the inbound
> interface into account (__xfrm_decode_session does not properly fill in
> the iif field of the flowi), so in the last global policy check, there
> is no way of differentiating a plaintext packet directly received from
> the network from a plaintext packet that was processed by a vti interface.

Input interface maching is not implemented, the xfrm_selector has
one ifindex field and this is interpreted as the output interface.
But I would not mind if someone would implement input interface maching.

I'll do another, hopefully final, RFC version of the vti4 paches today.
