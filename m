From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] fjes: Fix wrong netdevice feature flags
Date: Wed, 15 Mar 2017 13:41:56 +0300
Message-ID: <7ebd6b13-28f3-517b-efb5-4e56dc2e0f1f@cogentembedded.com>
References: <1489553270-7754-1-git-send-email-izumi.taku@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yasu.isimatu@gmail.com
To: Taku Izumi <izumi.taku@jp.fujitsu.com>, netdev@vger.kernel.org,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:33556 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751694AbdCOKl7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 06:41:59 -0400
Received: by mail-lf0-f47.google.com with SMTP id a6so5088384lfa.0
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 03:41:58 -0700 (PDT)
In-Reply-To: <1489553270-7754-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 3/15/2017 7:47 AM, Taku Izumi wrote:

> This patch fixes netdev->features for Extended Socket network device.
>
> Currently Extended Socket network device's netdev->feature claims
> NETIF_F_HW_CSUM, however this is completely wrong. There's no feature
> of checksum offloading.
> That causes invalid TCP/UDP checksum and packet rjection when IP

    Rejection.

> forwarding from Extended Socket network device to other network device.
>
> NETIF_F_HW_CSUM should be omitted.
>
> Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
[...]

MBR, Sergei
