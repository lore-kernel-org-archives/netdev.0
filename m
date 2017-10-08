From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next RFC 8/9] net: dsa: mv88e6xxx: add rx/tx
 timestamping support
Date: Sun, 8 Oct 2017 11:12:29 -0400
Message-ID: <20171008151228.h75zo7wmkqvocixs@localhost>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
 <1506612341-18061-9-git-send-email-brandon.streiff@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Erik Hons <erik.hons@ni.com>
To: Brandon Streiff <brandon.streiff@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1506612341-18061-9-git-send-email-brandon.streiff@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 28, 2017 at 10:25:40AM -0500, Brandon Streiff wrote:
> We also utilize a feature of the "generation 3" PTP hardware that lets
> us to embed the timestamp value into one of the reserved fields in the
> PTP header. This lets us extract the timestamp out of the header and
> avoid an SMI access in the RX codepath. (This implementation does not
> presently support the older generations.)

That is fine for the later models, but we really need the code to read
over MDIO as well.  You added .ptp_support = true for those older
switches, and so the present series won't work.

If it helps, maybe I can adapt the relevant code from my driver to
your work.

Thanks,
Richard
