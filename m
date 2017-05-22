From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 0/3] net-pktgen: Adjustments for some function implementations
Date: Mon, 22 May 2017 11:11:43 +0200
Message-ID: <79472009-7764-bb92-5f29-60bb21793cec@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Florian Westphal <fw@strlen.de>,
        =?UTF-8?B?R8O8bnRlciBSw7Zjaw==?= <linux@roeck-us.net>,
        John Fastabend <john.fastabend@gmail.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.14]:63790 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757613AbdEVJMw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 May 2017 05:12:52 -0400
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 22 May 2017 11:01:23 +0200

A few update suggestions were taken into account
from static source code analysis.

Markus Elfring (3):
  Improve four size determinations
  Delete an error message for a failed memory allocation in pktgen_create_thread()
  Adjust five checks for null pointers

 net/core/pktgen.c | 23 ++++++++++-------------
 1 file changed, 10 insertions(+), 13 deletions(-)

-- 
2.13.0
