From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: Fix inverted test for multiple CPU
 interface
Date: Sun, 22 Jan 2017 21:26:40 -0800
Message-ID: <6f7bc0c1-7c8c-38b4-0522-aecfd37d5c5a@gmail.com>
References: <1485119805-30338-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33841 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750703AbdAWF0m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 00:26:42 -0500
Received: by mail-pg0-f66.google.com with SMTP id t6so12745939pgt.1
        for <netdev@vger.kernel.org>; Sun, 22 Jan 2017 21:26:42 -0800 (PST)
In-Reply-To: <1485119805-30338-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 01/22/2017 01:16 PM, Andrew Lunn wrote:
> Remove the wrong !, otherwise we get false positives about having
> multiple CPU interfaces.
> 
> Fixes: b22de490869d ("net: dsa: store CPU switch structure in the tree")
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
