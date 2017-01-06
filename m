From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2 0/3] ip vrf: minor error message cleanups
Date: Thu,  5 Jan 2017 16:22:20 -0800
Message-ID: <1483662143-15242-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:34331 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030894AbdAFA3Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 19:29:16 -0500
Received: by mail-pg0-f41.google.com with SMTP id 14so894903pgg.1
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2017 16:29:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ahern (3):
  ip vrf: Fix error message when running exec as non-root user
  ip vrf: Improve error message for non-root user
  ip vrf: Clean up bpf related error messages

 ip/ipvrf.c |  6 +++++-
 lib/fs.c   | 16 ++++++++++++----
 2 files changed, 17 insertions(+), 5 deletions(-)

-- 
2.1.4
