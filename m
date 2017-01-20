From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net v2] bridge: netlink: call br_changelink() during
 br_dev_newlink()
Date: Fri, 20 Jan 2017 18:08:47 +0100
Message-ID: <20170120170847.GA1784@nanopsycho.orion>
References: <20170120165933.19991-1-cera@cera.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
        davem@davemloft.net, bridge@lists.linux-foundation.org,
        jiri@mellanox.com
To: Ivan Vecera <cera@cera.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33323 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751294AbdATRJA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 12:09:00 -0500
Received: by mail-wm0-f67.google.com with SMTP id r144so8156806wme.0
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 09:09:00 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170120165933.19991-1-cera@cera.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jan 20, 2017 at 05:59:33PM CET, cera@cera.cz wrote:
>Any bridge options specified during link creation (e.g. ip link add)
>are ignored as br_dev_newlink() does not process them.
>Use br_changelink() to do it.
>
>Fixes: 1332351 bridge: implement rtnl_link_ops->changelink

This is not the correct "Fixes" format.
