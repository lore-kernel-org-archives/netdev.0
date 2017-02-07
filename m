From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: tunnel: fix attribute checks in br_parse_vlan_tunnel_info
Date: Tue, 07 Feb 2017 05:24:16 -0800
Message-ID: <5899CA80.8030108@cumulusnetworks.com>
References: <c341a60f-f3d1-29f6-b825-5ebd1432e5b9@cumulusnetworks.com> <1486468006-8080-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
        Colin Ian King <colin.king@canonical.com>,
        "David S. Miller" <davem@davemloft.net>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34133 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754328AbdBGNYR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 08:24:17 -0500
Received: by mail-pf0-f182.google.com with SMTP id e4so33296514pfg.1
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 05:24:17 -0800 (PST)
In-Reply-To: <1486468006-8080-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/7/17, 3:46 AM, Nikolay Aleksandrov wrote:
> These checks should go after the attributes have been parsed otherwise
> we're using tb uninitialized.
>
> Fixes: efa5356b0d97 ("bridge: per vlan dst_metadata netlink support")
> Reported-by: Colin Ian King <colin.king@canonical.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
>  
ouch, am surprised i did not catch this. Thanks Colin and Nikolay.
