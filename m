From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: ath: Could not kill baseband RX
Date: Tue, 16 Aug 2011 09:11:00 -0700
Message-ID: <4E4A9694.1010803@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:60743 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751819Ab1HPQLV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2011 12:11:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

seems with the current I have hit:

ath: Could not kill baseband RX
[  966.943524] ath: Unable to reset channel (2412 MHz), reset status -5
[  966.943631] ath: Unable to set channel
[  967.066100] ath: Could not kill baseband RX
[  967.189233] ath: Unable to reset channel (2417 MHz), reset status -5
[  967.189294] ath: Unable to set channel
[  967.311597] ath: Could not kill baseband RX
[  967.434729] ath: Unable to reset channel (2422 MHz), reset status -5
[  967.434796] ath: Unable to set channel

full dmesg..:  http://fpaste.org/voy7/
wireless goes out, a reboot is the only way to get the wireless back up 
and running.

there is a similar bug, but looks different than this one(but could be 
wrong). https://bugzilla.kernel.org/show_bug.cgi?id=31702

Justin P. Mattock

