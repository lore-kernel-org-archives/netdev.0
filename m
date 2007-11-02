From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2][NETFILTER] Consolidate nf_sockopt and compat_nf_sockopt
Date: Fri, 02 Nov 2007 11:57:37 +0100
Message-ID: <472B02A1.40601@trash.net>
References: <4729F6F7.2020705@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45285 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751763AbXKBLAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2007 07:00:50 -0400
In-Reply-To: <4729F6F7.2020705@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelyanov wrote:
> Both lookup the nf_sockopt_ops object to call the get/set callbacks
> from, but they perform it in a completely similar way.
> 
> Introduce the helper for finding the ops.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org >


This conflicts with a cleanup patch from Alexey Dobriyan. I'll
push it upstream today, please resend after rediffing. Thanks.
