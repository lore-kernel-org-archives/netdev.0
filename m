From: David Miller <davem@davemloft.net>
Subject: sysfs_format_mac
Date: Tue, 16 Jul 2013 12:56:41 -0700 (PDT)
Message-ID: <20130716.125641.1190207010366517153.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39620 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932991Ab3GPT4l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 15:56:41 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 7884D587DE0
	for <netdev@vger.kernel.org>; Tue, 16 Jul 2013 12:56:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I assume that the only reason sysfs_format_mac() exists at all, and
don't just use scnprintf() calls with "%pm\n", is that some devices
have MAC addresses which are not 6 bytes in length.

But it's such a waste to have this special case piece of code
just for that.

It would make so much more sense to allow specifying a length
specifier to %pm and friends.
