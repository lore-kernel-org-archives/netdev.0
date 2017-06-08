From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next v2 02/19] net: bridge: Add support for offloading
 port attributes
Date: Thu, 8 Jun 2017 12:24:09 +0300
Message-ID: <5c6b5e2b-b777-f11e-adee-aaa7435a78bd@cumulusnetworks.com>
References: <20170608064428.4785-1-jiri@resnulli.us>
 <20170608064428.4785-3-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org, ivecera@redhat.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f173.google.com ([209.85.128.173]:35785 "EHLO
        mail-wr0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751584AbdFHJYM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 05:24:12 -0400
Received: by mail-wr0-f173.google.com with SMTP id q97so15881233wrb.2
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 02:24:12 -0700 (PDT)
In-Reply-To: <20170608064428.4785-3-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/06/17 09:44, Jiri Pirko wrote:
> From: Arkadi Sharshevsky <arkadis@mellanox.com>
> 
> Currently the flood, learning and learning_sync port attributes are
> offloaded by setting the SELF flag. Add support for offloading the
> flood and learning attribute through the bridge code. In case of
> setting an unsupported flag on a offloded port the operation will
> fail.
> 
> The learning_sync attribute doesn't have any software representation
> and cannot be offloaded through the bridge code.
> 
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  net/bridge/br_netlink.c   | 87 +++++++++++++++++++++++++++++++++++------------
>  net/bridge/br_private.h   | 10 ++++++
>  net/bridge/br_switchdev.c | 43 +++++++++++++++++++++++
>  3 files changed, 119 insertions(+), 21 deletions(-)
> 

LGTM, thanks!

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
