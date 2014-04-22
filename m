From: Alexey Charkov <alchark-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v2 0/3] net: via-rhine: add support for on-chip Rhine controllers
Date: Tue, 22 Apr 2014 19:28:06 +0400
Message-ID: <1398180489-20230-1-git-send-email-alchark@gmail.com>
References: <1390823503-24087-1-git-send-email-alchark@gmail.com>
Cc: Alexey Charkov <alchark-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: rl-7uj+XXdSDtwfv37vnLkPlQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ci5G2KO2hbZ+pU9mqzGVBQ@public.gmane.org,
	robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1390823503-24087-1-git-send-email-alchark-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This series introduces platform bus (OpenFirmware) binding for 
via-rhine, as used in various ARM-based Systems-on-Chip by 
VIA/WonderMedia.

This has been tested in OF configuration by myself on a WM8950-based VIA 
APC Rock development board and on a WM8850-based netbook, and in PCI
configuration by Roger.

Please note that the initial version of these patches was signed off by
Roger, but some time has passed since then, so I'm not including his
sign-off until explicit notice.

David, could you please take these to net-next if appropriate?

Thanks a lot,
Alexey

Changes since v1:
 - Fixed indentation of function arguments
 - Switched to 'dev_is_pci' instead of string comparison on bus name
 - Dropped 'rhine,revision' DT attribute, put the revision into OF match
        table instead
 - Included actual device tree nodes where applicable

Alexey Charkov (3):
  net: via-rhine: switch to generic DMA functions
  net: via-rhine: reduce usage of the PCI-specific struct
  net: via-rhine: add OF bus binding

 .../devicetree/bindings/net/via-rhine.txt          |  17 +
 arch/arm/boot/dts/vt8500.dtsi                      |   6 +
 arch/arm/boot/dts/wm8650.dtsi                      |   6 +
 arch/arm/boot/dts/wm8850.dtsi                      |   6 +
 drivers/net/ethernet/via/Kconfig                   |   2 +-
 drivers/net/ethernet/via/via-rhine.c               | 444 ++++++++++++---------
 6 files changed, 302 insertions(+), 179 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/via-rhine.txt

-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
