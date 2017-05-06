From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 0/2] KCM: Fine-tuning for three function implementations
Date: Sat, 6 May 2017 14:14:29 +0200
Message-ID: <d9601df3-94c8-f15c-3a54-770604caf6a6@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, Colin Ian King <colin.king@canonical.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jiri Slaby <jslaby@suse.cz>, Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([217.72.192.78]:49646 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751836AbdEFMOr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 6 May 2017 08:14:47 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 6 May 2017 14:11:22 +0200

Two update suggestions were taken into account
from static source code analysis.

Markus Elfring (2):
  Replace three seq_puts() calls by seq_putc()
  Use seq_puts() in kcm_format_psock()

 net/kcm/kcmproc.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

-- 
2.12.2
