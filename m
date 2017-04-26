From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH v2 net-next] bridge: add per-port broadcast flood flag
Date: Wed, 26 Apr 2017 17:19:31 +0300
Message-ID: <377cfb2f-dced-b164-6b7d-80ce2b5c7599@cumulusnetworks.com>
References: <1493214489-9921-1-git-send-email-mmanning@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Mike Manning <mmanning@brocade.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:36214 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1955451AbdDZOTe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 10:19:34 -0400
Received: by mail-wm0-f45.google.com with SMTP id u65so52005268wmu.1
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 07:19:33 -0700 (PDT)
In-Reply-To: <1493214489-9921-1-git-send-email-mmanning@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/04/17 16:48, Mike Manning wrote:
> Support for l2 multicast flood control was added in commit b6cb5ac8331b
> ("net: bridge: add per-port multicast flood flag"). It allows broadcast
> as it was introduced specifically for unknown multicast flood control.
> But as broadcast is a special case of multicast, this may also need to
> be disabled. For this purpose, introduce a flag to disable the flooding
> of received l2 broadcasts. This approach is backwards compatible and
> provides flexibility in filtering for the desired packet types.
> 
> Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Signed-off-by: Mike Manning <mmanning@brocade.com>
> ---
>  include/linux/if_bridge.h    |  1 +
>  include/uapi/linux/if_link.h |  1 +
>  net/bridge/br_forward.c      | 24 +++++++++++++++++-------
>  net/bridge/br_if.c           |  2 +-
>  net/bridge/br_netlink.c      |  3 +++
>  net/bridge/br_sysfs_if.c     |  2 ++
>  6 files changed, 25 insertions(+), 8 deletions(-)
> 

Thank you, now we can control all types.

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
