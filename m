From: Akshat Kakkar <akshat.1984@gmail.com>
Subject: ipset losing entries on its own
Date: Wed, 6 Sep 2017 15:38:45 +0530
Message-ID: <CAA5aLPhEseXhOqSK=6K=5J2q-zn+8FpxhqOBV5NqCPNMAJqhow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35535 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752241AbdIFKIq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 06:08:46 -0400
Received: by mail-pf0-f178.google.com with SMTP id g13so12123667pfm.2
        for <netdev@vger.kernel.org>; Wed, 06 Sep 2017 03:08:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am having ipset 6.32

The hash type is hash:ip

I am adding/deleting IP addresses to it dynamically using scripts.

However, it has been observed that at times few IPs (3-4 out of 4000)
are not found in the set though it was added. Also, logs show there
was not request for deletion of that IP from IPSet.

Is it a bug?
