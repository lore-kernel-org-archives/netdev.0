From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 0/3] net-ATM: Adjustments for several function implementations
Date: Mon, 9 Oct 2017 22:48:11 +0200
Message-ID: <10a92558-1105-b947-86a2-6ac763cca36d@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Augusto Mecking Caringi <augustocaringi@gmail.com>,
        Bhumika Goyal <bhumirks@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        David Windsor <dwindsor@gmail.com>,
        Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        Jarod Wilson <jarod@redhat.com>,
        Johannes Berg <johannes.berg@intel.com>,
        Kees Cook <keescook@chromium.org>,
        Mitchell Blank Jr <mitch@sfgoth.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 9 Oct 2017 22:30:33 +0200

Some update suggestions were taken into account
from static source code analysis.

Markus Elfring (3):
  Delete an error message for a failed memory allocation in five functions
  Improve a size determination in 12 functions
  Adjust 121 checks for null pointers

 net/atm/addr.c        |   2 +-
 net/atm/br2684.c      |  19 ++++----
 net/atm/clip.c        |   6 +--
 net/atm/lec.c         |  49 ++++++++++----------
 net/atm/mpc.c         | 126 ++++++++++++++++++++++++--------------------------
 net/atm/mpoa_caches.c |  75 +++++++++++++++---------------
 net/atm/pppoatm.c     |  11 ++---
 net/atm/proc.c        |   2 +-
 net/atm/signaling.c   |   2 +-
 9 files changed, 141 insertions(+), 151 deletions(-)

-- 
2.14.2
