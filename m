From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] DSA tagging mismatches
Date: Tue, 28 Oct 2014 15:28:51 -0400 (EDT)
Message-ID: <20141028.152851.316275875261379777.davem@davemloft.net>
References: <1414187045-8326-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34460 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750786AbaJ1T24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 15:28:56 -0400
In-Reply-To: <1414187045-8326-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Fri, 24 Oct 2014 23:44:03 +0200

> The second patch is a fix, which should be applied to -rc. It is
> possible to get a DSA configuration which does not work. The patch
> stops this happening.
> 
> The first patch detects this situation, and errors out the probe of
> DSA, making it more obvious something is wrong. It is not required to
> apply it -rc.
> 
> v2 fixes the use case pointed out by Florian, that a switch driver
> may use DSA_TAG_PROTO_NONE which the patch did not correctly handle.

Series applied, thanks Andrew.
