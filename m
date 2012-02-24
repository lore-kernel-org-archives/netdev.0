From: Joe Perches <joe@perches.com>
Subject: Another netdev project?
Date: Fri, 24 Feb 2012 10:08:08 -0800
Message-ID: <1330106888.18464.6.camel@joe2Laptop>
References: <1330099282-4588-1-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:43560 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753177Ab2BXSIL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Feb 2012 13:08:11 -0500
In-Reply-To: <1330099282-4588-1-git-send-email-danny.kukawka@bisect.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems you're doing some nice cleanups.

Maybe you could investigate consolidating all the
various link state change messages into a
.ndo_link_state_changed function so that perhaps a
standard dmesg mechanism could be used.
