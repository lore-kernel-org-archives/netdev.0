From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] bluetooth : put hci dev after del conn
Date: Mon, 18 Feb 2008 20:44:57 -0800 (PST)
Message-ID: <20080218.204457.167455192.davem@davemloft.net>
References: <20080218075555.GA5940@darkstar.te-china.tietoenator.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcel@holtmann.org, linux-kernel@vger.kernel.org,
	bluez-devel@lists.sf.net, netdev@vger.kernel.org
To: hidave.darkstar@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43362
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752159AbYBSEoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2008 23:44:20 -0500
In-Reply-To: <20080218075555.GA5940@darkstar.te-china.tietoenator.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Young <hidave.darkstar@gmail.com>
Date: Mon, 18 Feb 2008 15:55:55 +0800

> Move hci_dev_put to del_conn to avoid hci dev going away before hci conn.

This looks correct so I have applied it.

> Signed-off-by: Dave Young <hidave.darkstar@gmail.com> 

Please remove the extraneous space at the end of your
signoff line next time :-)

Also, I reworked the loop in del_conn() so that it no longer
generates a compile warning, so I had to apply your patch
by hand.
