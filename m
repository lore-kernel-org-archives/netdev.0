From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 04/26] rt2x00: EEPROM 93Cx6
Date: Sun, 3 Dec 2006 19:19:05 +0100
Message-ID: <200612031919.05228.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:19032 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1758841AbWLCSTf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 13:19:35 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4144307nfa
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 10:19:35 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rt2400pci, rt2500pci and rt61pci share exactly the
same code for the eeprom reading. The only difference
is that rt61pci has a slightly different register reading
approach. In any case we have a lot of duplicate code.
Create a new module eeprom_93cx6 inside the rt2x00 folder
and make rt2x00 use that.
As a bonus the entire eeprom is read into an array
to optimize eeprom usage. This also enables dummy eeprom
writing where the temporary buffer can be manipulated by
the user without permanently harming the eeprom.
This feature should have been enabled through ethtool,
but 3 days after this patch ethtool was removed from
d80211. This feature will be used when debugfs has been
implemented.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

http://www.mendiosus.nl/rt2x00/04_eeprom.diff
