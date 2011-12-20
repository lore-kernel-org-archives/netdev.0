From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 11/14] mac802154: slaves manipulation routine
Date: Mon, 19 Dec 2011 17:08:39 -0800
Message-ID: <1324343319.1742.5.camel@joe2Laptop>
References: <20111219163117.GA13123@avtobot.cybertron>
	 <1324312434-13151-11-git-send-email-alex.bluesman.smirnov@gmail.com>
	 <20111219.144353.627184888133427434.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	alexander@Lenovo.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:34170 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753309Ab1LTBIl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Dec 2011 20:08:41 -0500
In-Reply-To: <20111219.144353.627184888133427434.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-12-19 at 14:43 -0500, David Miller wrote:
> From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
> > +	if ((--priv->hw->open_count) == 0)
> This is more canonical as "if (!--priv->hw->open_count)".

Shrug.   I think this is more readable and
intelligible with the == 0.

A test of a non-bool or non-ptr to a specific value
seems reasonable to me.
