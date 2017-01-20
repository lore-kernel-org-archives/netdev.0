From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net v3] bridge: netlink: call br_changelink() during
 br_dev_newlink()
Date: Fri, 20 Jan 2017 19:10:42 +0100
Message-ID: <20170120181042.GB1784@nanopsycho.orion>
References: <20170120171217.20617-1-cera@cera.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
        davem@davemloft.net, bridge@lists.linux-foundation.org,
        jiri@mellanox.com
To: Ivan Vecera <cera@cera.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34894 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751800AbdATSKp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 13:10:45 -0500
Received: by mail-wm0-f67.google.com with SMTP id d140so8556443wmd.2
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 10:10:45 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170120171217.20617-1-cera@cera.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jan 20, 2017 at 06:12:17PM CET, cera@cera.cz wrote:
>Any bridge options specified during link creation (e.g. ip link add)
>are ignored as br_dev_newlink() does not process them.
>Use br_changelink() to do it.
>
>Fixes: 1332351 ("bridge: implement rtnl_link_ops->changelink")

Should have 12 chars. Other than that,

Reviewed-by: Jiri Pirko <jiri@mellanox.com>
