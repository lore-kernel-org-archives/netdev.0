From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 05/26] rt2x00: Byte ordering
Date: Sun, 3 Dec 2006 19:19:04 +0100
Message-ID: <200612031919.04942.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:18521 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1758802AbWLCSTf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 13:19:35 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4144331nfa
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 10:19:35 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Overhaul the byteordering mechanism.
All byteordering happens at the reading and writing
of the register/eeprom/descriptor instead of the
get/set_field functions.
This makes sparse very happy and reduces the errors
significantly.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

http://www.mendiosus.nl/rt2x00/05_byteorder.diff
