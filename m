From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 1/2] mpls: allow TTL propagation to IP packets
 to be configured
Date: Thu, 9 Mar 2017 19:40:59 -0700
Message-ID: <d23fe5a5-3f8e-4bc7-dbb1-af33de7a5e41@cumulusnetworks.com>
References: <1485808575-16852-1-git-send-email-rshearma@brocade.com>
 <1488933990-14490-1-git-send-email-rshearma@brocade.com>
 <1488933990-14490-2-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        roopa <roopa@cumulusnetworks.com>
To: Robert Shearman <rshearma@brocade.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:34336 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753437AbdCJClD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 21:41:03 -0500
Received: by mail-pg0-f47.google.com with SMTP id 77so33273266pgc.1
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 18:41:02 -0800 (PST)
In-Reply-To: <1488933990-14490-2-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/7/17 5:46 PM, Robert Shearman wrote:
> diff --git a/include/net/netns/mpls.h b/include/net/netns/mpls.h
> index d29203651c01..58e0e46c4a5c 100644
> --- a/include/net/netns/mpls.h
> +++ b/include/net/netns/mpls.h
> @@ -10,7 +10,9 @@ struct ctl_table_header;
>  
>  struct netns_mpls {
>  	size_t platform_labels;
> +	int ip_ttl_propagate;
>  	struct mpls_route __rcu * __rcu *platform_label;
> +
>  	struct ctl_table_header *ctl;
>  };
>  

I'd prefer the platform_labels stay with platform_label. ie., put the
new ip_ttl_propagate above platform_labels.
