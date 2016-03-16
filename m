From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [net-next 1/2] bonding: remove duplicate set of flag
 IFF_MULTICAST
Date: Wed, 16 Mar 2016 11:06:49 +0100
Message-ID: <56E93039.8050708@cumulusnetworks.com>
References: <1458122356-25021-1-git-send-email-zhangshengju@cmss.chinamobile.com>
 <1458122356-25021-2-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@cumulusnetworks.com,
	Veaceslav Falico <vfalico@gmail.com>
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>,
	davem@davemloft.net, j.vosburgh@gmail.com, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:33796 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934448AbcCPKGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 06:06:52 -0400
Received: by mail-wm0-f43.google.com with SMTP id p65so182010405wmp.1
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 03:06:52 -0700 (PDT)
In-Reply-To: <1458122356-25021-2-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/16/2016 10:59 AM, Zhang Shengju wrote:
> Remove unnecessary set of flag IFF_MULTICAST, since ether_setup
> already does this.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> ---
>  drivers/net/bonding/bond_main.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 

There're a few more bonding maintainers, I've added them to the CC list.

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
