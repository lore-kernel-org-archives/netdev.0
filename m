From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC PATCH 1/4] rtnetlink: new flag NLM_F_HW_OFFLOAD to indicate
 kernel object offload to hardware
Date: Sat, 22 Nov 2014 23:08:20 +0300
Message-ID: <5470ED34.4090809@cogentembedded.com>
References: <1416610170-21224-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shrijeet@cumulusnetworks.com, gospo@cumulusnetworks.com
To: roopa@cumulusnetworks.com, jiri@resnulli.us, sfeldma@gmail.com,
	jhs@mojatatu.com, bcrl@kvack.org, tgraf@suug.ch,
	john.fastabend@gmail.com, stephen@networkplumber.org,
	linville@tuxdriver.com, nhorman@tuxdriver.com,
	nicolas.dichtel@6wind.com, vyasevic@redhat.com,
	f.fainelli@gmail.com, buytenh@wantstofly.org, aviadr@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:43016 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbaKVUIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2014 15:08:22 -0500
Received: by mail-la0-f49.google.com with SMTP id hs14so5654980lab.8
        for <netdev@vger.kernel.org>; Sat, 22 Nov 2014 12:08:21 -0800 (PST)
In-Reply-To: <1416610170-21224-2-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/22/2014 1:49 AM, roopa@cumulusnetworks.com wrote:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>

> This patch adds new flags in netlink header nlmsg_flags to signal if the
> message is for the kernel, hw or both.

> This can be used to indicate hw offload for all kind of objects
> routes, fdb entries, neighs, link objects like bonds, bridges, vxlan.

> Adding it in the header makes it possible to use it accross all objects and
> across all messages (sets/gets/deletes).

> Other alternative to this is a per kernel object netlink attribute/flag.
> But that leads to duplicating the attribute in different subsystems.

> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>   include/uapi/linux/netlink.h |    2 ++
>   1 file changed, 2 insertions(+)

> diff --git a/include/uapi/linux/netlink.h b/include/uapi/linux/netlink.h
> index 1a85940..f78522d 100644
> --- a/include/uapi/linux/netlink.h
> +++ b/include/uapi/linux/netlink.h
> @@ -54,6 +54,8 @@ struct nlmsghdr {
>   #define NLM_F_ACK		4	/* Reply with ack, with zero or error code */
>   #define NLM_F_ECHO		8	/* Echo this request 		*/
>   #define NLM_F_DUMP_INTR		16	/* Dump was inconsistent due to sequence change */
> ++#define NLM_F_KERNEL       32      /* This msg is only for the kernel */

    I don't think you really meant double '+'.

> +#define NLM_F_HW_OFFLOAD	64	/* offload this msg to hw */
[...]

WBR, Sergei
