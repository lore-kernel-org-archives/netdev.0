From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH] ipmr: vrf: Find VIFs using the actual device
Date: Mon, 15 May 2017 21:50:46 -0700
Message-ID: <11682335-6d21-f8d1-0b20-7ea47a236823@gmail.com>
References: <20170515221444.4913-1-Thomas.Winter@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsa@cumulusnetworks.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        roopa <roopa@cumulusnetworks.com>
To: Thomas Winter <Thomas.Winter@alliedtelesis.co.nz>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36121 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751009AbdEPEuy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 00:50:54 -0400
Received: by mail-pf0-f193.google.com with SMTP id n23so17360318pfb.3
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 21:50:54 -0700 (PDT)
In-Reply-To: <20170515221444.4913-1-Thomas.Winter@alliedtelesis.co.nz>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/15/17 3:14 PM, Thomas Winter wrote:
> The skb->dev that is passed into ip_mr_input is
> the loX device for VRFs. When we lookup a vif
> for this dev, none is found as we do not create
> vifs for loopbacks. Instead lookup a vif for the
> actual device that the packet was received on,
> eg the vlan.
> 
> Signed-off-by: Thomas Winter <Thomas.Winter@alliedtelesis.co.nz>
> cc: David Ahern <dsa@cumulusnetworks.com>
> cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> cc: roopa <roopa@cumulusnetworks.com>
> ---
>  net/ipv4/ipmr.c | 18 ++++++++++++++++--
>  1 file changed, 16 insertions(+), 2 deletions(-)

LGTM

Acked-by: David Ahern <dsahern@gmail.com>
