From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH net-next v2 02/10] net: dsa: debugfs: add tree
Date: Fri, 8 Sep 2017 16:40:28 +0200
Message-ID: <20170908144028.GA13685@kroah.com>
References: <20170828191748.19492-1-vivien.didelot@savoirfairelinux.com>
 <20170828191748.19492-3-vivien.didelot@savoirfairelinux.com>
 <87shfxxoi4.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87shfxxoi4.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 08, 2017 at 10:18:27AM -0400, Vivien Didelot wrote:
> Hi Greg,
> 
> Can I ask for a quick review of this patch as well? It's the one adding
> the boilerplate for a single debugfs file, and I'm pretty sure it can be
> reduced somehow.

I don't see a patch here :(

> Also more important, you will notice what seems to be a bug to me:
> I can read or write a file even if I didn't mask the corresponding mode,
> hence the double check in dsa_debugfs_show and dsa_debugfs_write.

The mode can be changed by userspace, you shouldn't ever need to check
it in any debugfs calls, right?

thanks,

greg k-h
