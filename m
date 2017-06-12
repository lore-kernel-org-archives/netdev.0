From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net v3] net: ipmr: Fix some mroute forwarding issues in
 vrf's
Date: Sun, 11 Jun 2017 20:55:05 -0600
Message-ID: <af56ef0c-5979-12e0-f3cf-936c89cd2bdc@gmail.com>
References: <20170610203017.4085-1-sharpd@cumulusnetworks.com>
 <20170611.181556.1883936192698112580.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Thomas.Winter@alliedtelesis.co.nz,
        nikolay@cumulusnetworks.com, yotamg@mellanox.com,
        idosch@mellanox.com, roopa@cumulusnetworks.com
To: David Miller <davem@davemloft.net>, sharpd@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:33604 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751983AbdFLCzQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 22:55:16 -0400
Received: by mail-pg0-f49.google.com with SMTP id f185so40668382pgc.0
        for <netdev@vger.kernel.org>; Sun, 11 Jun 2017 19:55:16 -0700 (PDT)
In-Reply-To: <20170611.181556.1883936192698112580.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/11/17 4:15 PM, David Miller wrote:
> 
> Applied and queued up for -stable, thank you.
> 

The backport will need bcfc7d33110b; that commit should have had the
same Fixes tag -- e58e41596811 ("net: Enable support for VRF with ipv4
multicast")
