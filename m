From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 0/5] net-SCTP: Adjustments for three function implementations
Date: Mon, 22 May 2017 18:35:47 +0200
Message-ID: <2845df67-d35d-536a-0a53-b2eb83fe1ba5@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 22 May 2017 18:30:45 +0200

A few update suggestions were taken into account
from static source code analysis.

Markus Elfring (5):
  Use kmalloc_array() in sctp_init()
  Delete an error message for a failed memory allocation in sctp_init()
  Fix a typo in a comment line in sctp_init()
  Improve a size determination in sctp_inetaddr_event()
  Adjust one function call together with a variable assignment

 net/sctp/protocol.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

-- 
2.13.0
