From: Marcel Holtmann <marcel@holtmann.org>
Subject: Small Bluetooth fix for 2.6.27-rc6
Date: Fri, 12 Sep 2008 05:56:44 +0200
Message-ID: <1221191805.11498.14.camel@californication>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:48916 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753830AbYILB4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 21:56:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

we discovered one tiny regression that was introduced with the default
link policy change in 2.6.27-rc1. This small patch fixes it and I hope
the commit message is detailed and clear enough to understand what went
wrong.

I also got pretty much annoyed by the following compiler warning:

  CC [M]  net/bluetooth/af_bluetooth.o
net/bluetooth/af_bluetooth.c:60: warning: =E2=80=98bt_key_strings=E2=80=
=99 defined but not used
net/bluetooth/af_bluetooth.c:71: warning: =E2=80=98bt_slock_key_strings=
=E2=80=99 defined but not used

So I finally fixed it (even if I didn't cause it), but I don't know
what's your take on fixing compiler warnings in -rc phase. It can
certainly wait for the next merge window.

Regards

Marcel


Please pull from

    git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.=
6.git master

This will update the following files:

 net/bluetooth/hci_core.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

through these ChangeSets:

Marcel Holtmann (1):
    [Bluetooth] Fix regression from using default link policy



