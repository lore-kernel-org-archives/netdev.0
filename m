From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 0/5] atm: Adjustments for some function implementations
Date: Sun, 21 May 2017 22:12:40 +0200
Message-ID: <49543220-93e4-781c-877b-381277837152@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org,
        Augusto Mecking Caringi <augustocaringi@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jarod Wilson <jarod@redhat.com>,
        Javier Martinez Canillas <javier@osg.samsung.com>,
        Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 21 May 2017 22:09:11 +0200

A few update suggestions were taken into account
from static source code analysis.

Markus Elfring (5):
  Improve a size determination in four functions
  Delete an error message for a failed memory allocation in make_entry()
  Adjust 19 checks for null pointers
  Use seq_puts() in lec_info()
  Use seq_putc() in lec_info()

 net/atm/lec.c | 55 +++++++++++++++++++++++++++----------------------------
 1 file changed, 27 insertions(+), 28 deletions(-)

-- 
2.13.0
