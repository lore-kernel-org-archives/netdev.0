From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH net 0/3]  CAIF Bug-fixes.
Date: Thu, 12 Apr 2012 20:18:06 +0200
Message-ID: <1334254689-2843-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sjurbren@gmail.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:42120 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932923Ab2DLSSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 14:18:16 -0400
Received: by lahj13 with SMTP id j13so1789545lah.19
        for <netdev@vger.kernel.org>; Thu, 12 Apr 2012 11:18:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some simple bug fixes: plugging memory leaks and fixing the
log-level from err to dbg. I suppose these should go into v3.4.

Regards,
Sjur
--

Kim Lilliestierna (1):
  caif_hsi: use dev_dbg not dev_err for reporting

Sjur Br=C3=A6ndeland (1):
  caif-hsi: Free flip_buffer at shutdown

Tomasz Gregorek (1):
  caif: Fix memory leakage in the chnl_net.c.

 drivers/net/caif/caif_hsi.c |    9 +++++----
 net/caif/chnl_net.c         |    9 ++++++---
 2 files changed, 11 insertions(+), 7 deletions(-)

--=20
1.7.5.4
