From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [ANNOUNCE] iproute2 2.6.35
Date: Wed, 4 Aug 2010 11:03:23 -0700
Message-ID: <20100804110323.40439045@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: linux-net@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This version of iproute2 utilities intended for use with 2.6.35 or
later kernel, but should be backward compatible with older releases.
In addition to build and man page fixes, this release includes a
support for a couple of new kernel features:

   * 64 bit network device stats
   * multicast rules

he tar ball is available at:
  http://devresources.linuxfoundation.org/dev/iproute2/download/iproute2-2.6.35.tar.bz2

Repository:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

For more info on iproute2 see:
  http://www.linuxfoundation.org/collaborate/workgroups/networking/iproute2

Report problems (or enhancements) to the netdev@vger.kernel.org mailing list.

Changes since last release (2.6.34)

Andreas Henriksson (1):
      tc: make symbols loaded from tc action modules global.

Arnd Hannemann (1):
      iproute2: Add dsfield as alias for tos for ip rules

Ben Greear (1):
      iproute2: Fix batch-mode for mrules.

Jan Engelhardt (1):
      Add IFLA_STATS64 support

Mike Frysinger (3):
      tc: revert "echo" in install target
      dnet: fix strict aliasing warnings
      netem: fix installs of dist files

Patrick McHardy (1):
      ip: add support for multicast rules

Petr Lautrbach (1):
      iproute: fix tc generating ipv6 priority filter

Stephen Hemminger (5):
      Update kernel derived headers
      Update ARP header type table
      Fix NULL pointer reference when using basic match
      Fix byte order of ether address match for u32
      snapshot 100804

Steve Fink (1):
      ss -p is much too slow

Ulrich Weber (3):
      iproute2: filter routing entries based on clone flag
      iproute2: use get_user_hz() for IPv6 print_route
      iproute2: use int instead of long for RTAX_HOPLIMIT compare
