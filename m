From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: mvpp2: do not bypass the mvpp22_port_mii_set
 function
Date: Tue, 6 Jun 2017 18:44:30 +0300
Message-ID: <942ac798-e6f1-ce68-3651-c01c2e5ed60b@cogentembedded.com>
References: <20170606133615.20747-1-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gregory.clement@free-electrons.com, mw@semihalf.com,
        linux@armlinux.org.uk, linux-arm-kernel@lists.infradead.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, netdev@vger.kernel.org,
        thomas.petazzoni@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f44.google.com ([209.85.215.44]:33106 "EHLO
        mail-lf0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751281AbdFFPof (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 11:44:35 -0400
Received: by mail-lf0-f44.google.com with SMTP id a136so73555309lfa.0
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 08:44:34 -0700 (PDT)
In-Reply-To: <20170606133615.20747-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 06/06/2017 04:36 PM, Antoine Tenart wrote:

> The mvpp22_port_mii_set() function was added by 2697582144dd, but the

    Need to also specify the commit summary line enclosed in ("").

> function directly returns without doing anything. This return was used
> when debugging and wasn't removed before sending the patch. Fix this.
>
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
[...]

MBR, Sergei
