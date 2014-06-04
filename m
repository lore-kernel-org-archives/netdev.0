From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v10 1/7] xen-netback: Move grant_copy_op array
 back into struct xenvif.
Date: Wed, 04 Jun 2014 18:46:42 +0400
Message-ID: <538F3152.80501@cogentembedded.com>
References: <1401874247-3202-1-git-send-email-wei.liu2@citrix.com> <1401874247-3202-2-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, david.vrabel@citrix.com,
	zoltan.kiss@citrix.com, paul.durrant@citrix.com,
	a.j.bennieston@gmail.com,
	"Andrew J. Bennieston" <andrew.bennieston@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>, xen-devel@lists.xen.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:64761 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751329AbaFDOqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 10:46:38 -0400
Received: by mail-lb0-f170.google.com with SMTP id w7so4430846lbi.1
        for <netdev@vger.kernel.org>; Wed, 04 Jun 2014 07:46:36 -0700 (PDT)
In-Reply-To: <1401874247-3202-2-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/04/2014 01:30 PM, Wei Liu wrote:

> From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>

> This array was allocated separately in commit ac3d5ac2 ("xen-netback:
> fix guest-receive-side array sizes") due to it being very large, and a
> struct xenvif is allocated as the netdev_priv part of a struct
> net_device, i.e. via kmalloc() but falling back to vmalloc() if the
> initial alloc. fails.

> In preparation for the multi-queue patches, where this array becomes
> part of struct xenvif_queue and is always allocated through vzalloc(),
> move this back into the struct xenvif.

    Won't this cause an allocation failure and so break bisection at this patch?

> Signed-off-by: Andrew J. Bennieston <andrew.bennieston@citrix.com>
> Acked-by: Wei Liu <wei.liu2@citrix.com>

WBR, Sergei
