From: Johan Andersson <johan.andersson@transmode.se>
Subject: e1000e: Hardware CRC stripping doesn't work with 82566DM-2
Date: Wed, 06 Feb 2008 21:42:28 +0100
Message-ID: <47AA1BB4.8010802@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Auke Kok <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:45228 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756199AbYBFUrn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 15:47:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

In commit 140a74802894e9db57e5cd77ccff77e590ece5f3 a workaround for crc 
stripping was removed.
However, the hardware supported crc stripping now in use doesn't seem to 
work with the following chip:
Intel Corporation 82566DM-2 Gigabit Network Connection (rev 02) (8086:10bd)

I discovered this while trying to make this nic member of a bridge. 
Since some frames get too large for the bridge they are dropped, making 
it impossible to use this nic in a bridge.

Reverting this commit makes the nic and brigde work again.

Are there any more chips in this family suffering from this?

/Johan Andersson


