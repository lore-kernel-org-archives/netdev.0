From: David Miller <davem@davemloft.net>
Subject: Re: XFRM structures binary compability
Date: Sat, 17 Jan 2009 23:13:34 -0800 (PST)
Message-ID: <20090117.231334.141351829.davem@davemloft.net>
References: <496B56B7.3080703@trash.net>
	<20090114.145552.71463842.davem@davemloft.net>
	<200901161440.3616@centrum.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: klimes@centrum.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45793
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756077AbZARHNd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2009 02:13:33 -0500
In-Reply-To: <200901161440.3616@centrum.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jiri Klimes" <klimes@centrum.cz>
Date: Fri, 16 Jan 2009 14:40:02 +0100

> David, I'm afraid the fix is not correct.  xfrm_msg_min is not used
> just for length check, but mainly to find start of the netlink
> attributes.  Therefore the patch will work for the case with no
> attributes. However it won't work properly in case attributes are
> used (which is in most cases).  So, I suggest to revert the patch.

Thanks for catching this, I'll revert.
