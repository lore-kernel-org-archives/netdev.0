From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] net: VRF: Pass original iif to ip_route_input()
Date: Wed, 14 Sep 2016 13:29:46 -0600
Message-ID: <e05505c9-f60b-2241-4426-f70548c20efa@cumulusnetworks.com>
References: <20160912014553.20927-1-mark.tomlinson@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Mark Tomlinson <mark.tomlinson@alliedtelesis.co.nz>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36803 "EHLO
        mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760398AbcINT3t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 15:29:49 -0400
Received: by mail-pa0-f44.google.com with SMTP id id6so8151749pad.3
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2016 12:29:49 -0700 (PDT)
In-Reply-To: <20160912014553.20927-1-mark.tomlinson@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/11/16 7:45 PM, Mark Tomlinson wrote:
> Please note that while this patch fixes my issue, I am not entirely sure
> why the skb->dev is changed to the master device, so I am not sure this
> is the right fix.

Can you send a v2 dropping the above paragraph from the commit log.

> 
> Signed-off-by: Mark Tomlinson <mark.tomlinson@alliedtelesis.co.nz>
> ---
>  net/ipv4/ip_input.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)

And you can add

Acked-by: David Ahern <dsa@cumulusnetworks.com>
