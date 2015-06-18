From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC PATCH net-next v2 2/5] net: add phys ID compare helper to
 test if two IDs are the same
Date: Thu, 18 Jun 2015 17:11:14 +0300
Message-ID: <5582D182.80803@cogentembedded.com>
References: <1434577994-22409-1-git-send-email-sfeldma@gmail.com> <1434577994-22409-3-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, simon.horman@netronome.com,
	roopa@cumulusnetworks.com, ronen.arad@intel.com,
	john.r.fastabend@intel.com, andrew@lunn.ch, f.fainelli@gmail.com,
	linux@roeck-us.net, davidch@broadcom.com,
	stephen@networkplumber.org
To: sfeldma@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:35443 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751529AbbFROLR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2015 10:11:17 -0400
Received: by lbbwc1 with SMTP id wc1so53257942lbb.2
        for <netdev@vger.kernel.org>; Thu, 18 Jun 2015 07:11:16 -0700 (PDT)
In-Reply-To: <1434577994-22409-3-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 6/18/2015 12:53 AM, sfeldma@gmail.com wrote:

> From: Scott Feldman <sfeldma@gmail.com>

> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> ---
>   include/linux/netdevice.h |    7 +++++++
>   net/switchdev/switchdev.c |    8 ++------
>   2 files changed, 9 insertions(+), 6 deletions(-)

> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 7be616e1..63090ce 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -766,6 +766,13 @@ struct netdev_phys_item_id {
>   	unsigned char id_len;
>   };
>
> +static inline bool netdev_phys_item_id_same(struct netdev_phys_item_id *a,
> +					    struct netdev_phys_item_id *b)
> +{
> +	return ((a->id_len == b->id_len) &&
> +		(memcmp(a->id, b->id, a->id_len) == 0));

    Parens around the *return* expression not needed (and neither the ones 
around ==).

[...]

WBR, Sergei
