From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 0/10] rt2x00
Date: Sun, 27 Aug 2006 17:39:10 +0200
Message-ID: <200608271739.10503.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:46123 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751078AbWH0PjS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Aug 2006 11:39:18 -0400
Received: by nf-out-0910.google.com with SMTP id o25so1091661nfa
        for <netdev@vger.kernel.org>; Sun, 27 Aug 2006 08:39:17 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Here is a new update for rt2x00.
After these patches rt2x00 seems to slowly become active.
Current problematic issues:

Solid association but high packet loss (rt2400pci)
Very short association duration (rt2500pci)
On big endian machines device doesn't wake up (rt2500usb)
Hard to start association, and association is very short (rt2500usb)
Solid association but no packet transfer (rt61pci)
Only lives rarely, doesn't seem to do much (rt73usb)

Anyway here is the patch series for wireless-dev.
Note these patches are against the current wireless-dev tree,
without the crc and rfkill patches since those have not been
applied to the tree yet since they are waiting for maintainer approval.
This will not cause conflicts with the patch, but could cause some fuzz warnings
later when all patches are applied.

Ivo
