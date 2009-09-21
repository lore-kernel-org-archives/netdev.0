From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: 'cfg80211: fix SME connect' breaks b43 in latest net-2.6 and linux-2.6
Date: Mon, 21 Sep 2009 12:10:01 +0200
Message-ID: <4AB750F9.6070807@hartkopp.net>
References: <4AB4BF1F.7070501@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:45901 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755892AbZIUKKB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2009 06:10:01 -0400
In-Reply-To: <4AB4BF1F.7070501@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Johannes,

your commit 'cfg80211: fix SME connect' breaks my WPA2 WLAN connection on a
b43 adapter.

http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commitdiff;h=bbac31f4c0339f6c51afbd0edfb4959df9b53fa9

Oliver Hartkopp wrote:

> my b43 wireless card (Dell 830) is not working with the latest net-2.6 (and
> also linux-2.6 2.6.31-05767-gdf58bee).
> 
> net-2.6 2.6.31-03263-gc29854e is working
> net-2.6 2.6.31-03301-ga97e178 is broken

When reverting the mentioned commit it works again.

I'm running a Debian testing distro.

Regards,
Oliver
