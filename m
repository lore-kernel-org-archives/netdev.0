From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH net-next] net: fec: Clear and enable MIB counters on imx51
Date: Wed, 7 Jun 2017 10:32:03 -0300
Message-ID: <CAOMZO5DE30i+7Ddpf3Fx+WW8WUa61cariDukcYGtqaa9nk-pPg@mail.gmail.com>
References: <1496800629-24910-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        Chris Healy <cphealy@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:34033 "EHLO
        mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751543AbdFGNcE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 09:32:04 -0400
Received: by mail-oi0-f43.google.com with SMTP id o65so5531035oif.1
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 06:32:04 -0700 (PDT)
In-Reply-To: <1496800629-24910-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 6, 2017 at 10:57 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> Both the IMX51 and IMX53 datasheet indicates that the MIB counters
> should be cleared during setup. Otherwise random numbers are returned
> via ethtool -S.  Add a quirk and a function to do this.
>
> Tested on an IMX51.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Thanks for the fix:

Reviewed-by: Fabio Estevam <fabio.estevam@nxp.com>
