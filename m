From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 4/6] net: dsa: remove unused arguments of tagger rcv
Date: Tue, 30 May 2017 15:55:33 -0400
Message-ID: <87shjmyv9m.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170530183319.10718-1-vivien.didelot@savoirfairelinux.com> <20170530183319.10718-5-vivien.didelot@savoirfairelinux.com> <b31811c6-d019-da1f-9df0-0ad00264204b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b31811c6-d019-da1f-9df0-0ad00264204b@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

> I actually have a patch pending that adds support for HW
> insertion/extraction of switch tags (broadcom HW supports that) which
> require the orig_dev to be there so we know what features are supported
> by the master network device.

Is orig_dev really needed in the tagging implementation, or only in the
layer above? (dsa_slave_xmit and dsa_switch_rcv.)

> Do you mind dropping this one from your patch series?

I don't mind if they are actually needed in taggers. I'd wait for
reviews of the other patches before respinning though.

Thanks,

        Vivien
