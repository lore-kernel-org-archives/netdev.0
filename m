From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH next 3/3] ipvlan: Introduce l3s mode
Date: Fri, 9 Sep 2016 16:26:23 -0600
Message-ID: <ddb5c5e8-6656-754a-8178-09096a2d333e@cumulusnetworks.com>
References: <1473458010-18571-1-git-send-email-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Mahesh Bandewar <maheshb@google.com>
To: Mahesh Bandewar <mahesh@bandewar.net>,
        netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35556 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755410AbcIIW02 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 18:26:28 -0400
Received: by mail-pf0-f169.google.com with SMTP id w87so33325188pfk.2
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 15:26:28 -0700 (PDT)
In-Reply-To: <1473458010-18571-1-git-send-email-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/9/16 3:53 PM, Mahesh Bandewar wrote:
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 0c5415b05ea9..95edd1737ab5 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -149,6 +149,7 @@ config IPVLAN
>      tristate "IP-VLAN support"
>      depends on INET
>      depends on IPV6
> +    select NET_L3_MASTER_DEV

depends on instead of select?
