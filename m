From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2] bridge: fdb add and delete tracepoints
Date: Tue, 29 Aug 2017 09:46:05 -0700
Message-ID: <8737eb73-3437-5529-6f4d-7aa52c770357@gmail.com>
References: <1503980568-35240-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com,
        bridge@lists.linux-foundation.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:34444 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751180AbdH2QqO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 12:46:14 -0400
Received: by mail-wr0-f194.google.com with SMTP id z91so2660620wrc.1
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 09:46:13 -0700 (PDT)
In-Reply-To: <1503980568-35240-1-git-send-email-roopa@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/28/2017 09:22 PM, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> A few useful tracepoints to trace bridge forwarding
> database updates.
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Small nit below, but probably not a candidate for a v3

> ---

> +
> +	TP_printk("dev %s addr %02x:%02x:%02x:%02x:%02x:%02x vid %u nlh_flags %04x ndm_flags = %02x",

Small nit, any particular reason why ndm_flags got a special treatment
with an equal character and not the other?

> +		  __get_str(dev), __entry->addr[0], __entry->addr[1],
> +		  __entry->addr[2], __entry->addr[3], __entry->addr[4],
> +		  __entry->addr[5], __entry->vid,
> +		  __entry->nlh_flags, __entry->ndm_flags)
-- 
Florian
