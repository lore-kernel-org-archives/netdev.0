From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 02/10] net: dsa: debugfs: add tree
Date: Fri, 08 Sep 2017 10:18:27 -0400
Message-ID: <87shfxxoi4.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170828191748.19492-1-vivien.didelot@savoirfairelinux.com> <20170828191748.19492-3-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Chris Healy <cphealy@gmail.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:45230 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751166AbdIHOVw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 10:21:52 -0400
In-Reply-To: <20170828191748.19492-3-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Greg,

Can I ask for a quick review of this patch as well? It's the one adding
the boilerplate for a single debugfs file, and I'm pretty sure it can be
reduced somehow.

Also more important, you will notice what seems to be a bug to me:
I can read or write a file even if I didn't mask the corresponding mode,
hence the double check in dsa_debugfs_show and dsa_debugfs_write.


Thanks,

        Vivien
