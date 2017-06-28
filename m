From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH] net: ipmr: Add ipmr_rtm_getroute
Date: Wed, 28 Jun 2017 21:09:20 +0300
Message-ID: <75b7eb48-7289-753a-8edb-496c588b6fcb@cumulusnetworks.com>
References: <20170628175857.20447-1-sharpd@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Donald Sharp <sharpd@cumulusnetworks.com>, netdev@vger.kernel.org,
        roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f169.google.com ([209.85.128.169]:32817 "EHLO
        mail-wr0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751516AbdF1SJX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 14:09:23 -0400
Received: by mail-wr0-f169.google.com with SMTP id r103so178537321wrb.0
        for <netdev@vger.kernel.org>; Wed, 28 Jun 2017 11:09:23 -0700 (PDT)
In-Reply-To: <20170628175857.20447-1-sharpd@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/06/17 20:58, Donald Sharp wrote:
> Add to RTNL_FAMILY_IPMR, RTM_GETROUTE the ability
> to retrieve one S,G mroute from a specified table.
> 
> *,G will return mroute information for just that
> particular mroute if it exists.  This is because
> it is entirely possible to have more S's then
> can fit in one skb to return to the requesting
> process.
> 
> Signed-off-by: Donald Sharp <sharpd@cumulusnetworks.com>
> ---
>  net/ipv4/ipmr.c | 63 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 62 insertions(+), 1 deletion(-)
> 

This is targeted at net-next.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
