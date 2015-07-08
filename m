From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: Re: [PATCH net-next v4 1/4] net core: Add protodown support.
Date: Wed, 08 Jul 2015 19:07:28 -0400
Message-ID: <559DAD30.20806@cumulusnetworks.com>
References: <1436389465-3077-2-git-send-email-anuradhak@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, wkok@cumulusnetworks.com
To: anuradhak@cumulusnetworks.com, davem@davemloft.net,
	sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:35435 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224AbbGHXHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 19:07:30 -0400
Received: by qget71 with SMTP id t71so107784655qge.2
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 16:07:30 -0700 (PDT)
In-Reply-To: <1436389465-3077-2-git-send-email-anuradhak@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/8/15 5:04 PM, anuradhak@cumulusnetworks.com wrote:
> diff --git a/include/uapi/linux/if.h b/include/uapi/linux/if.h
> index 9cf2394..8d60fe7 100644
> --- a/include/uapi/linux/if.h
> +++ b/include/uapi/linux/if.h
> @@ -156,6 +156,12 @@ enum {
>   	IF_LINK_MODE_DORMANT,	/* limit upward transition to dormant */
>   };
>
> +/* proto_flags - port state information can be passed to the switch driver and
> + * used to determine the phys state of the switch port */
> +enum {
> +	IF_PROTOF_DOWN		= 1<<0	/* set switch port phys state down */

It might be better to use BIT(0) provided by linux/bitopts.h

> +};
> +
