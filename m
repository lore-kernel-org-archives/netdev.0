From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 2/5] net: add phys ID compare helper to test if
 two IDs are the same
Date: Thu, 9 Jul 2015 15:15:35 +0300
Message-ID: <559E65E7.3040607@cogentembedded.com>
References: <1436397403-62412-1-git-send-email-sfeldma@gmail.com>
 <1436397403-62412-3-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com
To: sfeldma@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:34748 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065AbbGIMPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 08:15:38 -0400
Received: by lagx9 with SMTP id x9so244912221lag.1
        for <netdev@vger.kernel.org>; Thu, 09 Jul 2015 05:15:36 -0700 (PDT)
In-Reply-To: <1436397403-62412-3-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 7/9/2015 2:16 AM, sfeldma@gmail.com wrote:

> From: Scott Feldman <sfeldma@gmail.com>

> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> ---
>   include/linux/netdevice.h |    7 +++++++
>   net/switchdev/switchdev.c |    8 ++------
>   2 files changed, 9 insertions(+), 6 deletions(-)

[...]
> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
> index 84f77a0..e16586f 100644
> --- a/net/switchdev/switchdev.c
> +++ b/net/switchdev/switchdev.c
> @@ -906,13 +906,9 @@ static struct net_device *switchdev_get_dev_by_nhs(struct fib_info *fi)
>   		if (switchdev_port_attr_get(dev, &attr))
>   			return NULL;
>
> -		if (nhsel > 0) {
> -			if (prev_attr.u.ppid.id_len != attr.u.ppid.id_len)
> +		if (nhsel > 0 &&
> +		    !netdev_phys_item_id_same(&prev_attr.u.ppid, &attr.u.ppid))
>   				return NULL;

    This line should be re-indented now, it starts too far to the right.

[...]

WBR, Sergei
