From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH net-next] net: fec: Clear and enable MIB counters on imx51
Date: Fri, 9 Jun 2017 21:01:26 -0400
Message-ID: <CAP=VYLr4_jjiXs8bD+9LU3TvEmmJqcU=MRFaKV-Co12mYNE0WA@mail.gmail.com>
References: <1496800629-24910-1-git-send-email-andrew@lunn.ch> <20170607.100742.9158707718791478.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: andrew@lunn.ch, netdev <netdev@vger.kernel.org>,
        nikita.yoush@cogentembedded.com, fabio.estevam@nxp.com,
        cphealy@gmail.com,
        "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f196.google.com ([209.85.217.196]:33979 "EHLO
        mail-ua0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751573AbdFJBB6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 21:01:58 -0400
In-Reply-To: <20170607.100742.9158707718791478.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 7, 2017 at 10:07 AM, David Miller <davem@davemloft.net> wrote:
> From: Andrew Lunn <andrew@lunn.ch>
> Date: Wed,  7 Jun 2017 03:57:09 +0200
>
>> Both the IMX51 and IMX53 datasheet indicates that the MIB counters
>> should be cleared during setup. Otherwise random numbers are returned
>> via ethtool -S.  Add a quirk and a function to do this.

Seems to break one of the automated linux-next builds:

http://kisskb.ellerman.id.au/kisskb/buildresult/13057702/

A mindless automated bisect reports:

2b30842b23b9e6796c7bd5f0916fd2ebf6b7d633 is the first bad commit
commit 2b30842b23b9e6796c7bd5f0916fd2ebf6b7d633
Author: Andrew Lunn <andrew@lunn.ch>
Date:   Wed Jun 7 03:57:09 2017 +0200

    net: fec: Clear and enable MIB counters on imx51

Paul.
