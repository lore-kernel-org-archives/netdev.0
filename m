From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [ANNOUNCE] iproute2 v3.6.0
Date: Mon, 1 Oct 2012 09:01:24 -0700
Message-ID: <20121001090124.2f8ce0f7@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I am happy to announce the update to iproute2 for v3.6 kernel.
In addition to lots of documentation and minor bugfixes,
this version contains support for controlling the forwarding
tables of software and external device bridges.

This also means that if there are changes to iproute2 to support
features added to 3.7 merge window, please submit them now.


Iproute2 package is available at:
  http://kernel.org/pub/linux/utils/net/iproute2/iproute2-3.6.0.tar.gz

You can download the source from:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

---

Andreas Schwab (1):
      iproute2: Fix various manpage formatting nits

Chris Webb (1):
      Correct the bridge command name in help messages

Dan Kenigsberg (1):
      utils: invarg: msg precedes the faulty arg

Eric Dumazet (1):
      ss: report SK_MEMINFO_BACKLOG

Florian Westphal (2):
      tc: add ipset ematch
      add ematch man page

Jiri Pirko (1):
      iplink: add support for num[tr]xqueues

John Fastabend (4):
      iproute2: Add FDB print and update cmds for self and master
      iproute2: build failure due to missing '\' in Makefile
      iproute2: bridge: remove replace and change options
      iproute2: bridge: finish removing replace option in man pages

Julian Anastasov (3):
      iproute2: add libgenl files
      iproute2: use libgenl in ipl2tp
      iproute2: GENL: merge GENL_REQUEST and GENL_INITIALIZER

Li Wei (3):
      iproute2: fix typo in help message.
      iproute2: configure: Add search path for 64bit library.
      iproute2: tc.8: update UNITS section.

Mathias Krause (1):
      configure: remove TMPDIR on exit

Mike Frysinger (1):
      Fix regression with 'ip address show'

Oliver Hartkopp (1):
      iproute2: Add missing tc-ematch.8 for man page installation

Pavel Emelyanov (4):
      iproute: Fix errno propagation from rtnl_talk
      iproute: Add magic cookie to route dump file
      iproute: Add route showdump command (v2)
      iproute: Add ability to save, restore and show the interfaces' addresses (resend)

Rostislav Lisovy (2):
      add can.h
      Ematch used to classify CAN frames according to their identifiers

Saurabh (1):
      iproute2: VTI support for ip link command.

Saurabh Mohan (1):
      VTI support for ip tunnel

Stephen Hemminger (9):
      Update to 3.6.0-pre headers
      Fix formatting of ip.8 family man page
      Explain TC class id limits
      Update can.h to 3.6-rc2
      Install all tc and ip sub pages
      man: make sure tc man page gets installed
      Add support for AF_BRIDGE
      update header files to 3.6
      v3.6.0

Werner Fink (1):
      Change how pdf doc's are created

Xose Vazquez Perez (1):
      Fix Makefile's
