From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH 00/12] Fix various section mismatches and build errors.
Date: Sun, 26 Jun 2011 12:19:54 +0100
Message-ID: <17dd5038b15d7135791aadbe80464a13c80758d3.1309182742.git.ralf@linux-mips.org>
Cc: dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org,
        linux-mips@linux-mips.org, linux-scsi@vger.kernel.org,
        linux-serial@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
        Alan Cox <alan@linux.intel.com>,
        Brent Casavant <bcasavan@sgi.com>,
        David Airlie <airlied@linux.ie>,
        "David
Return-path: <linux-mips-bounce@linux-mips.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

I'm getting screen and screens full of section mismatches from my test
builds of the current kernel to the point where it's sometimes more
meaningful messages get hidden by the bulk of mismatches.  This is the
first round of fixes with more to come.

  Ralf

 drivers/gpu/drm/radeon/radeon_clocks.c |    4 ++--
 drivers/leds/leds-lp5521.c             |    4 ++--
 drivers/leds/leds-lp5523.c             |    4 ++--
 drivers/misc/ioc4.c                    |    2 +-
 drivers/net/3c509.c                    |    2 +-
 drivers/net/3c59x.c                    |    2 +-
 drivers/net/depca.c                    |   25 +++++++++++++------------
 drivers/net/hp100.c                    |    2 +-
 drivers/net/ne3210.c                   |   12 +++++++-----
 drivers/net/tulip/de4x5.c              |    2 +-
 drivers/scsi/sim710.c                  |    2 +-
 drivers/tty/serial/Kconfig             |    2 +-
 12 files changed, 33 insertions(+), 30 deletions(-)
