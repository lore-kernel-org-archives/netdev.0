From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: Re: [PATCH] ehea: Use the standard logging functions
Date: Tue, 30 Nov 2010 15:03:56 -0200
Message-ID: <4CF52E7C.7010308@linux.vnet.ibm.com>
References: <1290790908.11971.303.camel@Joe-Laptop> <1290792387-12331-1-git-send-email-leitao@linux.vnet.ibm.com> <1290814046.11971.320.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp01.br.ibm.com ([32.104.18.85]:35841 "EHLO
	e24smtp01.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751764Ab0K3REC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 12:04:02 -0500
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by e24smtp01.br.ibm.com (8.14.4/8.13.1) with ESMTP id oAUHOQ4U021342
	for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 15:24:26 -0200
Received: from d24av02.br.ibm.com (d24av02.br.ibm.com [9.8.31.93])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oAUH2a4D1892538
	for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 14:02:38 -0300
Received: from d24av02.br.ibm.com (loopback [127.0.0.1])
	by d24av02.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oAUH3ebI010405
	for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 15:03:40 -0200
In-Reply-To: <1290814046.11971.320.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe,

Thanks for the patch. Please make sure that it applies over the last 
Davem's tree. He just committed one patch that will probably conflict 
with this patch.

Also, this patch is printing:

ibmebus port0: foobarmessage

Instead of

ehea: foobarmessage

But this is a driver issue, and your patch just exposed this problem. I 
will send a patch for this soon.

Thanks
Breno

On 11/26/2010 09:27 PM, Joe Perches wrote:
> Remove ehea_error, ehea_info and ehea_debug macros.
> Use pr_fmt, pr_<level>, netdev_<level>  and netif_<level>  as appropriate.
> Fix messages to use trailing "\n", some messages had an extra one
> as the old ehea_<level>  macros added a trailing "\n".
> Coalesced long format strings.
>
> Uncompiled/untested.
>
> Signed-off-by: Joe Perches<joe@perches.com>
Acked-by: Breno Leitao <leitao@linux.vnet.ibm.com>

