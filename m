From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v2 02/10] net: dsa: debugfs: add tree
Date: Fri, 8 Sep 2017 15:03:16 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD00716ED@AcuExch.aculab.com>
References: <20170828191748.19492-1-vivien.didelot@savoirfairelinux.com>
 <20170828191748.19492-3-vivien.didelot@savoirfairelinux.com>
 <87k21944rq.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "kernel@savoirfairelinux.com" <kernel@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Chris Healy <cphealy@gmail.com>
To: 'Vivien Didelot' <vivien.didelot@savoirfairelinux.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.182]:57532 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750842AbdIHPDZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 11:03:25 -0400
In-Reply-To: <87k21944rq.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot
> Sent: 08 September 2017 15:57
...
> > > Also more important, you will notice what seems to be a bug to me:
> > > I can read or write a file even if I didn't mask the corresponding mode
> > > hence the double check in dsa_debugfs_show and dsa_debugfs_write.
> >
> > The mode can be changed by userspace, you shouldn't ever need to check
> > it in any debugfs calls, right?
> 
> Correct. But this happens even if the file mode isn't changed by
> userspace in the meantime, which seemed weird to me. e.g. echo
> redirected to a -r--r--r-- debugfs entry will call dsa_debugfs_write.

root will be able to write using 'root' permissions, regardless of
the directory entry.

	David
