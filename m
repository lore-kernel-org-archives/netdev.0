From: Stephen Suryaputra Lin <stephen.suryaputra.lin@gmail.com>
Subject: Faster TCP keepalive
Date: Fri, 23 Jun 2017 15:58:17 -0400
Message-ID: <20170623195817.GA13904@ssuryaputra-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:33788 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754781AbdFWT6W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 15:58:22 -0400
Received: by mail-pg0-f54.google.com with SMTP id f127so25109381pgc.0
        for <netdev@vger.kernel.org>; Fri, 23 Jun 2017 12:58:22 -0700 (PDT)
Received: from ssuryaputra-desktop ([12.38.14.193])
        by smtp.gmail.com with ESMTPSA id x5sm11755876pfi.103.2017.06.23.12.58.19
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 12:58:20 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings,

I'm writing this to probe if there has been thoughts or efforts in
allowing sub-second TCP keep alive interval? One application is for TCP
connections between IP hosts connected by an internal backplane where a
faster detection is a necessity and the increased traffic can be
accommodated.

Suggestions on other ways to quickly tearing down TCP connections to a
rebooted host in the application above are welcomed.

Thank you,

Stephen.
