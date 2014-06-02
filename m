From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v9 1/7] xen-netback: Move grant_copy_op array back into
 struct xenvif.
Date: Mon, 02 Jun 2014 16:50:01 +0400
Message-ID: <538C72F9.5040809@cogentembedded.com>
References: <1401706212-8208-1-git-send-email-wei.liu2@citrix.com> <1401706212-8208-2-git-send-email-wei.liu2@citrix.com>
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
Received: from mail-la0-f54.google.com ([209.85.215.54]:44462 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753009AbaFBMuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 08:50:03 -0400
Received: by mail-la0-f54.google.com with SMTP id pv20so2571753lab.13
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2014 05:50:00 -0700 (PDT)
In-Reply-To: <1401706212-8208-2-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 02-06-2014 14:50, Wei Liu wrote:

> From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>

> This array was allocated separately in commit ac3d5ac2 due to it being

    Please also specify that commit's summary in parens.

> very large, and a struct xenvif is allocated as the netdev_priv part of
> a struct net_device, i.e. via kmalloc() but falling back to vmalloc() if
> the initial alloc. fails.

> In preparation for the multi-queue patches, where this array becomes
> part of struct xenvif_queue and is always allocated through vzalloc(),
> move this back into the struct xenvif.

> Signed-off-by: Andrew J. Bennieston <andrew.bennieston@citrix.com>
> Acked-by: Wei Liu <wei.liu2@citrix.com>

WBR, Sergei
