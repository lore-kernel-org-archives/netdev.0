From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [patch net-next v3 3/6] mlxsw: spectrum_router: Use FIB
 notifications instead of switchdev calls
Date: Mon, 26 Sep 2016 14:11:03 +0300
Message-ID: <20160926111103.GA11100@splinter>
References: <1474887154-6286-1-git-send-email-jiri@resnulli.us>
 <1474887154-6286-4-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, linville@tuxdriver.com,
        andy@greyhouse.net, f.fainelli@gmail.com, dsa@cumulusnetworks.com,
        jhs@mojatatu.com, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, ivecera@redhat.com, kaber@trash.net,
        john@phrozen.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:50537 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S965050AbcIZLLG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 07:11:06 -0400
Content-Disposition: inline
In-Reply-To: <1474887154-6286-4-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 26, 2016 at 12:52:31PM +0200, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> Until now, in order to offload a FIB entry to HW we use switchdev op.
> However that has limits. Mainly in case we need to make the HW aware of
> all route prefixes configured in kernel. HW needs to know those in order
> to properly trap appropriate packets and pass the to kernel to do
> the forwarding. Abort mechanism is now handled within the mlxsw driver.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Reviewed-by: Ido Schimmel <idosch@mellanox.com>

Thanks
