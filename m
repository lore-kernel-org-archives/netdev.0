From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] vhost/net: length miscalculation
Date: Wed, 07 Jan 2015 23:58:00 +0300
Message-ID: <54AD9DD8.2080008@cogentembedded.com>
References: <1420620847-24477-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alex Williamson <alex.williamson@redhat.com>,
	Greg Kurz <gkurz@linux.vnet.ibm.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:62770 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753608AbbAGU6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 15:58:05 -0500
Received: by mail-lb0-f178.google.com with SMTP id u14so1761042lbd.37
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 12:58:03 -0800 (PST)
In-Reply-To: <1420620847-24477-1-git-send-email-mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01/07/2015 11:55 AM, Michael S. Tsirkin wrote:

> commit 8b38694a2dc8b18374310df50174f1e4376d6824
>      vhost/net: virtio 1.0 byte swap
> had this chunk:
> -       heads[headcount - 1].len += datalen;
> +       heads[headcount - 1].len = cpu_to_vhost32(vq, len - datalen);

> This adds datalen with the wrong sign, causing guest panics.

> Fixes: 8b38694a2dc8b18374310df50174f1e4376d6824

    The format of this tag assumes 12-digit SHA1 hash and the commit 
description enclosed in parens and double quotes. See 
Documentation/SubmittingPatches.

> Reported-by: Alex Williamson <alex.williamson@redhat.com>
> Suggested-by: Greg Kurz <gkurz@linux.vnet.ibm.com>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

WBR, Sergei
