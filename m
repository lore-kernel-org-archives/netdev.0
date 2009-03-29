From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 0/2] kaweth: Fix locking and cleanup code
Date: Sun, 29 Mar 2009 18:31:07 -0500
Message-ID: <49D004BB.3010505@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755337AbZC2Xhg@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When I dug out an old Peracom USB Ethernet Adapter, I was surprised to see that
it worked, but soon discovered that it generated several suspicious kernel log
messages.

The first of the 2 patches that follow incorporate changes in locking that allow
the device to be used on SMP systems. The second patch removes other errors that
were logged and cleans up the code a little.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
