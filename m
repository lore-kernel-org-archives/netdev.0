From: Robin Kreis <r.kreis@uni-bremen.de>
Subject: ip netns exec after unshare --map-root-user
Date: Thu, 8 May 2014 14:06:03 +0200
Message-ID: <20140508140603.67734f6e@sat>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gabriel-2.zfn.uni-bremen.de ([134.102.20.37]:40602 "EHLO
	smtp.uni-bremen.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751820AbaEHMTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 08:19:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

After 'unshare --map-root-user --mount' and ensuring that /var/run/netns
is writable (possibly by binding another directory there), a network
namespace can be created by running 'ip netns create test'.

However, 'ip netns exec test sh' exits when it attempts to
unmount /sys.  I don't think that the failing to umount /sys should be a
fatal error, because the following mount call ensures that /sys has the
right contents.  I checked that 'ip netns exec' works fine when the
error returned by umount is ignored.  Should I submit a patch to
iproute2?

Please CC me, because I'm not subscribed to the mailing list.

Greetings,
Robin Kreis
