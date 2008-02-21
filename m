From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: New sparse warning in net/mac80211/debugfs_sta.c
Date: Thu, 21 Feb 2008 01:34:27 -0800
Message-ID: <1203586467.20345.14.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:31249 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762246AbYBUJeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 04:34:13 -0500
Received: by wa-out-1112.google.com with SMTP id v27so4416697wah.23
        for <netdev@vger.kernel.org>; Thu, 21 Feb 2008 01:34:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 0795af5729b18218767fab27c44b1384f72dc9ad
Author: Joe Perches <joe@perches.com>
Date:   Wed Oct 3 17:59:30 2007 -0700

    [NET]: Introduce and use print_mac() and DECLARE_MAC_BUF()
   =20
    This is nicer than the MAC_FMT stuff.
   =20
    Signed-off-by: Joe Perches <joe@perches.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

Introduced:
net/mac80211/debugfs_sta.c: In function =E2=80=98ieee80211_sta_debugfs_=
add=E2=80=99:
net/mac80211/debugfs_sta.c:211: warning: statement with no effect

Does print_mac modify the mac buffer in-place, or return a new buffer?

Harvey

