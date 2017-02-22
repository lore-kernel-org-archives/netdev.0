From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 2/2] tcp: account for ts offset only if tsecr not zero
Date: Wed, 22 Feb 2017 05:32:37 -0800
Message-ID: <1487770357.9415.45.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1487759036-2800-1-git-send-email-alexey.kodanev@oracle.com>
         <1487759036-2800-2-git-send-email-alexey.kodanev@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>
To: Alexey Kodanev <alexey.kodanev@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36102 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932179AbdBVNcj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 08:32:39 -0500
Received: by mail-pg0-f65.google.com with SMTP id z128so410717pgb.3
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 05:32:39 -0800 (PST)
In-Reply-To: <1487759036-2800-2-git-send-email-alexey.kodanev@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-02-22 at 13:23 +0300, Alexey Kodanev wrote:
> We can get SYN with zero tsecr, don't apply offset in this case.
> 
> Fixes: ee684b6f2830 ("tcp: send packets with a socket timestamp")
> Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>
> ---
> v2: no changes from the previous version

Acked-by: Eric Dumazet <edumazet@google.com>
