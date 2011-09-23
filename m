From: Holger Hans Peter Freyther <holger@freyther.de>
Subject: Question regarding wanrouter module
Date: Fri, 23 Sep 2011 11:34:07 +0200
Message-ID: <4E7C528F.4010303@freyther.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sysmocom.de ([78.46.147.233]:21068 "EHLO mail.symoco.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752669Ab1IWJlM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Sep 2011 05:41:12 -0400
Received: from [192.168.0.101] (91-64-80-26-dynip.superkabel.de [91.64.80.26])
	by mail.symoco.de (Postfix) with ESMTPSA id C2F3A254342F
	for <netdev@vger.kernel.org>; Fri, 23 Sep 2011 09:35:16 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

at some point the Sangoma wanrouter and device drivers were merged in the
kernel. Somewhere in 2006 (8db60bcf3021921e2d10d158641792d640e52fe8) the
drivers were removed as Sangoma wanted to maintain them themselves. Later some
of the functionality got removed (ce0ecd594d78710422599918a608). In the kernel
it appears that cycx_x25.c and isdn_x25iface.c make use of the wanrouter.

Fast forward to today, Sangoma provides a wanrouter.ko as well (they didn't
bother to change the symbol names or module name). I wonder if there are any
plans to improve the situation, e.g. rename the kernel module, change symbols,
or if there would be objections to trying to add functionality to the kernel
wanrouter.ko again?

cheers
	holger
