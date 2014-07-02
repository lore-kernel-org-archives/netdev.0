From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/5] net: systemport: PM and Wake-on-LAN support
Date: Wed, 2 Jul 2014 09:44:17 -0700
Message-ID: <CAGVrzcaS4SOZxoDCCQCRXAueaP=OikBt8eDNjiH4Ju5eGu_L=w@mail.gmail.com>
References: <1404274120-5717-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:33894 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752090AbaGBQo6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 12:44:58 -0400
Received: by mail-ob0-f172.google.com with SMTP id uy5so12585454obc.3
        for <netdev@vger.kernel.org>; Wed, 02 Jul 2014 09:44:57 -0700 (PDT)
In-Reply-To: <1404274120-5717-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-07-01 21:08 GMT-07:00 Florian Fainelli <f.fainelli@gmail.com>:
> Hi David,
>
> This patchset brings Power Management and Wake-on-LAN support to the
> Broadcom SYSTEM PORT driver.

David, feel free to drop this patch series, I will submit a
preliminary patchset that fixes the checkpatch.pl errors/warnings in
the systemport driver before moving on to add these features again.

Thank you!

>
> S2 and S3 modes are supported, while we only support Wake-on-LAN using
> MagicPackets for now
>
> Florian Fainelli (5):
>   net: systemport: update umac_enable_set to take a bitmask
>   net: systemport: add bcm_sysport_netif_{enable,stop}
>   net: systemport: add suspend and resume support
>   net: systemport: rename rx_csum_en to rx_chk_en
>   net: systemport: add Wake-on-LAN support
>
>  .../bindings/net/broadcom-systemport.txt           |   3 +-
>  drivers/net/ethernet/broadcom/bcmsysport.c         | 378 +++++++++++++++++++--
>  drivers/net/ethernet/broadcom/bcmsysport.h         |  14 +-
>  3 files changed, 361 insertions(+), 34 deletions(-)
>
> --
> 1.9.1
>



-- 
Florian
