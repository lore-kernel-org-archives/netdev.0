From: Johannes Berg <johannes@sipsolutions.net>
Subject: network manager confused with bcm43xx-d80211?
Date: Mon, 14 Aug 2006 10:18:26 +0200
Message-ID: <44E031D2.8070106@sipsolutions.net>
References: <44E02F41.2060300@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:5765 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750731AbWHNISa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 04:18:30 -0400
To: Michael Buesch <mbuesch@freenet.de>, dcbw@redhat.com
In-Reply-To: <44E02F41.2060300@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For whatever reason, nm always thinks that my default wlan0 device is a 
*wired* device. I do wonder where the bug is, but couldn't pinpoint it 
yet, any ideas? mm version is 0.6.3. I'd have thought it would go by the 
presence of wireless extensions, but if so it uses some call to detect 
it that isn't implemented here...

johannes

