From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH] dsa: mv88e6xxx: Fix error handling in mv88e6xxx_set_port_state
Date: Thu, 16 Apr 2015 06:46:52 -0700
Message-ID: <552FBD4C.4070405@roeck-us.net>
References: <1429161162-2028-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:50595 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933584AbbDPNqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 09:46:55 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1Yik87-003izy-5Z
	for netdev@vger.kernel.org; Thu, 16 Apr 2015 13:46:55 +0000
In-Reply-To: <1429161162-2028-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/15/2015 10:12 PM, Guenter Roeck wrote:
> Return correct error code if _mv88e6xxx_reg_read returns an error.
>
> Fixes: facd95b2e0ec0 ("net: dsa: mv88e6xxx: Add Hardware bridging support")
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

I should have given proper credit.

Reported-by: kbuild test robot <fengguang.wu@intel.com>

For the curious, neither W=1, W=2, C-1, C=2, nor sparse report this problem,
at least not with gcc 4.9.1.

Guenter
