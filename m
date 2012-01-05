From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [ANNOUNCE] iproute2 3.2.0
Date: Thu, 5 Jan 2012 14:42:01 -0800
Message-ID: <20120105144201.67348e16@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus released 3.2, and this means it is time for another release
of iproute2. Lots of little build and typo fixes.
The real visible changes in this release are:
  * better manual pages
  * L2TPv3 support
  * improved RED options
  * netem additions for loss models
  * iptables integration fixes

Download:
  http://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-3.2.0.tar.gz

Repository:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

This version is signed with my GPG public key

Report problems (or enhancements) to the netdev@vger.kernel.org mailing list.

---
Eric Dumazet (5):
      ss: report ecnseen
      red: give a hint about burst value
      red: make burst optional
      red: harddrop support and cleanups
      netem: fix a typo in explain()

Florian Westphal (1):
      tc: man: add man page for stochastic fair blue

Greg Rose (1):
      iproute2: Add new command to ip link to enable/disable VF spoof check

Hagen Paul Pfeifer (1):
      netem: add man-page

Jan Engelhardt (3):
      iproute2: avoid use of implicit declarations
      iproute2: proper detection of libxtables position and flags
      iproute2: fix calling up the xt action

Stephen Hemminger (14):
      Update to 3.2.0-rc2 headers
      Split up ip man page
      Update to latest 3.2 kernel headers
      netem: fix man page
      netem: add support for 4 state and GE loss model
      libnetlink: change rtnl_send() to take void *
      libnetlink: add more attribute functions
      libnetlink: remove unused junk callback
      libnetlink: add attribute access inline functions
      l2tp: Add l2tp support
      ematch: fix warning about yyerror and const
      ematch: fix warning about unused input()
      README cleanup's
      v3.2.0

Thomas Jarosch (2):
      tc: Remove unused variable 'res'.
      tc: Use correct variable type for get_distribution() result
