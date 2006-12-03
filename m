From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 00/26] rt2x00
Date: Sun, 3 Dec 2006 19:18:49 +0100
Message-ID: <200612031918.49959.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:19032 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1758779AbWLCSTI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 13:19:08 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4144307nfa
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 10:19:06 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This patch series will bring rt2x00 completely up to date.
This includes the compile fixes after last d80211 update,
and brings so many fixes it is hard to summarize them.
Basically what it comes down to is that with this version
several people have managed to get the drivers working
and even have master mode operational in some situations.

Of course it is not yet bug free, after the last d80211 update
several people have reported crashes when the driver
was still loaded while doing a shutdown. The kernel
traces are very vague and don't give a good clue on where the
problem might come from, so there isn't much to say about that yet.

Note that this patch series contains the crc-itu-t patch. I have intentionally
put this patch at the end of the series, because its succes with that patch
last time I had send it.
This patch had earlier been send as a module for the /lib folder in the kernel,
but besides Randy Dunlap on the linux-kernel mailing list nobody has responded
either on this list or on the linux-kernel list.
So instead of placing it in the /lib folder of the linux kernel, I have this time
placed it in the rt2x00 folder where it should be acceptable.

Another new module that has been added is the eeprom_93cx6 module,
that has been generically build, which means that it is not rt2x00 specific.
I kept it in the rt2x00 folder since only rt2x00 uses it, and I have not
looked for other drivers that might need this module.

Some of the patches are too big to be inlined into the seperate mails,
so those have been placed online.

Ivo
