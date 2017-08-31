From: Radu Rendec <rrendec@arista.com>
Subject: virtio_net: ethtool supported link modes
Date: Thu, 31 Aug 2017 18:04:04 +0100
Message-ID: <1504199044.22080.11.camel@arista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>
To: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Looking at the code in virtnet_set_link_ksettings, it seems the speed
and duplex can be set to any valid value. The driver will "remember"
them and report them back in virtnet_get_link_ksettings.

However, the supported link modes (link_modes.supported in struct
ethtool_link_ksettings) is always 0, indicating that no speed/duplex
setting is supported.

Does it make more sense to set (at least a few of) the supported link
modes, such as 10baseT_Half ... 10000baseT_Full?

I would expect to see consistency between what is reported in
link_modes.supported and what can actually be set. Could you please
share your opinion on this?

Thank you,
Radu Rendec
