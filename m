From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 03/26] rt2x00: descriptors
Date: Sun, 3 Dec 2006 19:19:05 +0100
Message-ID: <200612031919.05515.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:25433 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1759963AbWLCSTh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 13:19:37 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4144386nfa
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 10:19:37 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove txd and rxd descriptor structures.
All access to the descriptors should be done
by treating the descriptor as a register.
For this we do add a desc structure containing
a array, and several methods for reading and writing
to that array.
This is prepares rt2x00 for the overhaul of the
byteordering mechanism.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

http://www.mendiosus.nl/rt2x00/03_descriptor.diff
