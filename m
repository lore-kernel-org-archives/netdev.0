From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] net: netdev_kobject_init: annotate with __init
Date: Mon, 06 Jan 2014 19:13:08 +0400
Message-ID: <52CAC804.9080603@cogentembedded.com>
References: <1388967611-14263-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:38603 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753888AbaAFPNK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 10:13:10 -0500
Received: by mail-la0-f54.google.com with SMTP id b8so10106547lan.27
        for <netdev@vger.kernel.org>; Mon, 06 Jan 2014 07:13:08 -0800 (PST)
In-Reply-To: <1388967611-14263-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06-01-2014 4:20, Daniel Borkmann wrote:

> netdev_kobject_init() is only being called from __init context,
> that is, net_dev_init(), so annotate it with __init as well, thus
> the kernel can take this as a hint that the function is used only
> during the initialization phase and free up used memory resources
> after its invocation.

> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
[...]

> diff --git a/net/core/net-sysfs.h b/net/core/net-sysfs.h
> index bd7751e..2745a1b 100644
> --- a/net/core/net-sysfs.h
> +++ b/net/core/net-sysfs.h
> @@ -1,7 +1,7 @@
>   #ifndef __NET_SYSFS_H__
>   #define __NET_SYSFS_H__
>
> -int netdev_kobject_init(void);
> +int __init netdev_kobject_init(void);

    There's no need to also annotate function prototype.

WBR, Sergei
