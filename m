From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 12/26] rt2x00: Interface initialization
Date: Sun, 3 Dec 2006 19:19:02 +0100
Message-ID: <200612031919.02268.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:24664 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1758834AbWLCSTb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 13:19:31 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4144389nfa
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 10:19:30 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Correctly let the non-monitor and monitor interfaces
excist peacefully together. Make sure the configuration
is always accurate and allows the correct packets to
come through, let the interface enable the radio at
the correct time etc. etc.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

http://www.mendiosus.nl/rt2x00/12_interface.diff
