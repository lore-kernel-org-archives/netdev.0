From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Add firmware label support to iproute2
Date: Thu, 12 Aug 2010 14:12:40 -0400
Message-ID: <20100812141240.417949e2@s6510>
References: <20100812173537.GA29784@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matt_domsch@dell.com,
	charles_rose@dell.com, jordan_hargrave@dell.com
To: Narendra K <Narendra_K@dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38083 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753401Ab0HLSMo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Aug 2010 14:12:44 -0400
In-Reply-To: <20100812173537.GA29784@auslistsprd01.us.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Aug 2010 12:35:37 -0500
Narendra K <Narendra_K@dell.com> wrote:

> +#ifndef LIBNETDEVNAME_PRESENT
>  			filter_dev = *argv;
> +#else
> +			if (netdev_alias_to_kernelname(*argv, kernel_name) < 0)
> +				show_firmware_alias_usage(*argv);
> +			filter_dev = kernel_name;
> +#endif
>  		}

like the kernel, I don't like ifdef cases in main code.
You should put in stub inline that returns appropriate error.

What happens if alias matches existing interface name?
