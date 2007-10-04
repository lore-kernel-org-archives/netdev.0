From: Roland Dreier <rdreier@cisco.com>
Subject: Vague maybe ppp-related panic report for 2.6.23-rc9
Date: Thu, 04 Oct 2007 11:12:42 -0700
Message-ID: <ada4ph6da05.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3-in.cisco.com ([171.71.176.72]:42669 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754490AbXJDSMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 14:12:44 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm running 2.6.23-rc9 on my laptop, and when in a coffee shop I use
a Verizon EVDO card to get network access.  This is a kyocera device
that looks like a serial adapter behind an ohci usb controller, and
uses the airprime driver (for usb device 0c88:17da).  The actual IP
networking is ppp over that serial adapter.

The connection is slightly flaky (I blame this on the Verizon
coverage), so I end up restarting things every so often.  The point of
this email (at last) is that I've just seen my second panic (only
info: blinking caps lock led, since I've been in X) that seems
correlated to stopping/restarting pppd.

Sorry for the lack of detail -- I've just switched to running in the
console so if I can provoke the crash again I'll get a little more
info.  I just wanted to mention this in case someone has seen
something similar or has any good ideas about how to capture debugging
output on a laptop (when I'm not home and have no other boxes handy).

 - R.
