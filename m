From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Hidden SSID's
Date: Fri, 26 Jan 2007 21:48:01 -0600
Message-ID: <45BACB71.2080107@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:36269 "EHLO
	mtiwmhc13.worldnet.att.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751693AbXA0DsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jan 2007 22:48:09 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Is there a convention regarding the information that a wireless MAC layer should provide when
reporting scan data from an AP with a hidden SSID?

In ieee80211, the software inserts the string "<hidden>" for such an AP, which seems to give
wpa_supplicant fits because it rejects the SSID before even looking at the encryption data. Is this
the normal convention?

Thanks,

Larry


