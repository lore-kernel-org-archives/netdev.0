From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH RESEND 0/4]
Date: Wed, 3 Jan 2007 21:29:34 +0100
Message-ID: <200701032129.34879.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:55122 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932080AbXACUaH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jan 2007 15:30:07 -0500
Received: by nf-out-0910.google.com with SMTP id o25so7801012nfa
        for <netdev@vger.kernel.org>; Wed, 03 Jan 2007 12:30:05 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

These patches have been send during 2006 but never
have been applied or rejected. Even after sending requests
for updates on these patches.
So I have no idea if you had rejected them, simply
overlooked them, or if they are still in your pending list.

Short summary of which patches are being resend:

- crc-itu-t
This has been send to the list during the summer around
the same time as the initial patch for rfkill. It had also been
send to the linux-kernel list with a CC to you with a request
for comment.

- eeprom_93cx6
This has been send to the list1 or 2 months ago. After the
initial patch a feature request for eeprom write support was
made. Those 2 patches have now been merged into a single patch.

Both of the libraries come from rt2x00, and this patch merely
moves them to the location for more generic routines.
Both the crc as the eeprom handling can be used by different
drivers (some drivers also use the same implementation, which
in my opinion would jusitify these 2 modules to be in the lib folder).

Ivo
