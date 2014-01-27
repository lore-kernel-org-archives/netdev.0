From: Alexey Charkov <alchark-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 0/3] Resubmit: net: via-rhine: add support for on-chip Rhine controllers
Date: Mon, 27 Jan 2014 15:51:40 +0400
Message-ID: <1390823503-24087-1-git-send-email-alchark@gmail.com>
References: <1385227995-3956-1-git-send-email-alchark@gmail.com>
Cc: Alexey Charkov <alchark-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ci5G2KO2hbZ+pU9mqzGVBQ@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rl-7uj+XXdSDtwfv37vnLkPlQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1385227995-3956-1-git-send-email-alchark-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This series introduces platform bus (OpenFirmware) binding for 
via-rhine, as used in various ARM-based Systems-on-Chip by 
VIA/WonderMedia.

This has been tested in OF configuration by myself on a WM8950-based VIA 
APC Rock development board, and in PCI configuration by Roger.

Unfortunately, I can't find my original submission from 30 Nov in any of 
the mailing list archives (must have done something stupid while 
sending). However, Roger seems to have received the patches fine, tested 
them on PCI and signed off, so I'm including his Signed-off-by: with 
this submission along with my own.

Please note that this series does not include any ifdefs for either PCI 
or OF case, so in Roger's set-up the third patch increased module size 
from 39372 to 40868 bytes (+3.8%). I'm following the example of 
via-velocity here, which didn't have ifdefs either (and I believe it is 
cleaner this way).

Not sure if it's appropriate for 3.14 at this point, but getting it 
merged to -next would be much appreciated.

Best regards,
Alexey

Alexey Charkov (3):
  net: via-rhine: switch to generic DMA functions
  net: via-rhine: reduce usage of the PCI-specific struct
  net: via-rhine: add OF bus binding

 .../devicetree/bindings/net/via-rhine.txt          |  18 +
 drivers/net/ethernet/via/Kconfig                   |   2 +-
 drivers/net/ethernet/via/via-rhine.c               | 403 ++++++++++++---------
 3 files changed, 260 insertions(+), 163 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/via-rhine.txt

-- 
1.8.5.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
