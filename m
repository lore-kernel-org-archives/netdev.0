From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 00/10] staging/irda/net: Adjustments for several function
 implementations
Date: Thu, 12 Oct 2017 12:38:02 +0200
Message-ID: <8152401b-d68d-c4fe-2619-82a09e0c52ec@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
        Al Viro <viro@zeniv.linux.org.uk>,
        Corentin Labbe <clabbe.montjoie@gmail.com>,
        David Howells <dhowells@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Georgiana Chelu <georgiana.chelu93@gmail.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Johannes Berg <johannes.berg@intel.com>,
        Julia Lawall <julia.lawall@lip6.fr>,
        Samuel Ortiz <samuel@sortiz.org>,
        Srishti Sharma <srishtishar@gmail.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Yuan Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Language: en-GB
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 12 Oct 2017 11:25:43 +0200

Several update suggestions were taken into account
from static source code analysis.

Markus Elfring (10):
  Improve a size determination in 20 functions
  Delete ten error messages for a failed memory allocation
  Adjust 385 checks for null pointers
  Delete an unnecessary variable initialisation in irlap_recv_discovery_xid_cmd()
  Delete an unnecessary variable initialisation in irlap_recv_discovery_xid_rsp()
  Delete an unnecessary variable initialisation in two functions
  Delete an unnecessary variable initialisation in four functions
  Use common error handling code in irias_new_object()
  Combine some seq_printf() calls in two functions
  Use seq_puts() in four functions

 drivers/staging/irda/net/af_irda.c            |  56 +++++----
 drivers/staging/irda/net/discovery.c          |  31 +++--
 drivers/staging/irda/net/ircomm/ircomm_core.c |  10 +-
 drivers/staging/irda/net/ircomm/ircomm_tty.c  |   4 +-
 drivers/staging/irda/net/irda_device.c        |   2 +-
 drivers/staging/irda/net/iriap.c              |  61 +++++-----
 drivers/staging/irda/net/iriap_event.c        |  34 +++---
 drivers/staging/irda/net/irias_object.c       | 116 ++++++++-----------
 drivers/staging/irda/net/irlan/irlan_common.c |   3 +-
 drivers/staging/irda/net/irlap.c              |  84 +++++++-------
 drivers/staging/irda/net/irlap_event.c        |  77 ++++++------
 drivers/staging/irda/net/irlap_frame.c        |  74 ++++++------
 drivers/staging/irda/net/irlmp.c              | 161 ++++++++++++--------------
 drivers/staging/irda/net/irlmp_event.c        |  50 ++++----
 drivers/staging/irda/net/irlmp_frame.c        |  24 ++--
 drivers/staging/irda/net/irnetlink.c          |   2 +-
 drivers/staging/irda/net/irproc.c             |   2 +-
 drivers/staging/irda/net/irqueue.c            |  32 ++---
 drivers/staging/irda/net/irsysctl.c           |   4 +-
 drivers/staging/irda/net/irttp.c              |  75 ++++++------
 drivers/staging/irda/net/parameters.c         |  12 +-
 drivers/staging/irda/net/qos.c                |  20 ++--
 drivers/staging/irda/net/timer.c              |  12 +-
 drivers/staging/irda/net/wrapper.c            |   3 +-
 24 files changed, 450 insertions(+), 499 deletions(-)

-- 
2.14.2

