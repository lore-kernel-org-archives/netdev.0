From: David Brownell <david-b@pacbell.net>
Subject: 2.6.27-rc ... iwl3945 regression?
Date: Wed, 13 Aug 2008 17:35:42 -0700
Message-ID: <200808131735.42451.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp118.sbc.mail.sp1.yahoo.com ([69.147.64.91]:44415 "HELO
	smtp118.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752573AbYHNAfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 20:35:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I haven't looked into this yet, maybe it's just a kernel config change
of some kind ...


Userspace is Ubuntu 8.04 with NetworkManager and nm-applet; nothing
changed there recently.

2.6.26 works as expected ... unless I have the RF switch at "off",
when I left-click the applet, I get a list of cells available.  And
it will spontaneously join the right one.  It Just Works (yay!).

But with 2.6.27-rc, that's not true.  Left-click shows me two "Wired"
networks, "Intel Corporation PRO/Wireless 3945ABG Network Connection"
replacing the list of cells I would expect.  Status of RF switch
at boot doesn't matter.

However, "iwlist scan" shows a dozen cells or so ... so the issue
would seem to be that somehow wlan0 or wmaster0 started to look like
wireful links, instead of wireless ones.  (Seen early in RC0, and
just now verified as being in RC3.)


Does this sound familiar to anyone?  Got a fix that's better than
sticking to a 2.6.26 kernel?  :)

- Dave
