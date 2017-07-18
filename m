From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] mdio_bus: Remove unneeded gpiod NULL check
Date: Tue, 18 Jul 2017 12:56:27 +0300
Message-ID: <6f984a9c-e6d3-fd0a-6719-fa9032d43d1d@cogentembedded.com>
References: <1500325749-8382-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        Fabio Estevam <fabio.estevam@nxp.com>
To: Fabio Estevam <festevam@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:34468 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751457AbdGRJ4a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 05:56:30 -0400
Received: by mail-lf0-f47.google.com with SMTP id t72so9485061lff.1
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 02:56:30 -0700 (PDT)
In-Reply-To: <1500325749-8382-1-git-send-email-festevam@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 7/18/2017 12:09 AM, Fabio Estevam wrote:

> From: Fabio Estevam <fabio.estevam@nxp.com>
> 
> The gpiod API checks for NULL descriptors, so there is no need to
> duplicate the check in the driver.

    Won't this result in kernel WARNING when GPIO is disabled?

> Signed-off-by: Fabio Estevam <fabio.estevam@nxp.com>
[...]

MBR, Sergei
