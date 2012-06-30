From: Marc Haber <mh+netdev@zugschlus.de>
Subject: [IPv6] How to wait for pending SLAAC
Date: Sat, 30 Jun 2012 13:10:34 +0200
Message-ID: <20120630111033.GA17266@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.131.164]:51838 "EHLO
	torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754196Ab2F3LkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2012 07:40:03 -0400
Received: from mh by torres.zugschlus.de with local (Exim 4.72)
	(envelope-from <mh+netdev@zugschlus.de>)
	id 1SkvZS-0004VY-0T
	for netdev@vger.kernel.org; Sat, 30 Jun 2012 13:10:34 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I would like to have my system wait for the first SLAAC attempt during
bootup. To do this, I have written a script that waits until no more
IP address is found in "tentative" state.

Unfortunately, this is so fast that the script terminates before the
first address reaches "tentative" state.

Is there a way to find out whether the system is trying to do SLAAC on
any interface (for example information inside /proc or /sys), so that
one can wait for the IP address to appear, or is a fixed "sleep 5" the
only thing one can do here?

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 31958061
Nordisch by Nature |  How to make an American Quilt | Fax: *49 621 31958062
