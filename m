From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] rtnetlink: Handle IFLA_MASTER parameter when processing
 rtnl_newlink
Date: Mon, 30 Jan 2017 15:57:53 -0800
Message-ID: <20170130155753.4f3bb068@xeon-e3>
References: <20170130232346.29761-1-theuns.verwoerd@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com
To: Theuns Verwoerd <theuns.verwoerd@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33775 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753362AbdA3X6O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 18:58:14 -0500
Received: by mail-pf0-f174.google.com with SMTP id y143so95389632pfb.0
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 15:57:55 -0800 (PST)
In-Reply-To: <20170130232346.29761-1-theuns.verwoerd@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 31 Jan 2017 12:23:46 +1300
Theuns Verwoerd <theuns.verwoerd@alliedtelesis.co.nz> wrote:

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

Thanks it came through without modification by email client or server this time.
