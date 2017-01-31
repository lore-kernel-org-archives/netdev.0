From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] rtnetlink: Handle IFLA_MASTER parameter when processing
 rtnl_newlink
Date: Tue, 31 Jan 2017 14:49:23 -0700
Message-ID: <8cca96fb-572e-b7ac-92b0-916cbef1e60c@cumulusnetworks.com>
References: <20170130232346.29761-1-theuns.verwoerd@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Theuns Verwoerd <theuns.verwoerd@alliedtelesis.co.nz>,
        netdev@vger.kernel.org, roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34798 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750775AbdAaV6X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 16:58:23 -0500
Received: by mail-pf0-f179.google.com with SMTP id e4so111441667pfg.1
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 13:58:23 -0800 (PST)
In-Reply-To: <20170130232346.29761-1-theuns.verwoerd@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/30/17 4:23 PM, Theuns Verwoerd wrote:
> Allow a master interface to be specified as one of the parameters when
> creating a new interface via rtnl_newlink.  Previously this would
> require invoking interface creation, waiting for it to complete, and
> then separately binding that new interface to a master.
> 
> In particular, this is used when creating a macvlan child interface for
> VRRP in a VRF configuration, allowing the interface creator to specify
> directly what master interface should be inherited by the child,
> without having to deal with asynchronous complications and potential
> race conditions.
> 
> Signed-off-by: Theuns Verwoerd <theuns.verwoerd@alliedtelesis.co.nz>
> ---
>  net/core/rtnetlink.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 

I can't see any harm in doing the enslavement in the same command that creates the link and it does simplify VRR setup.

Acked-by: David Ahern <dsa@cumulusnetworks.com>
