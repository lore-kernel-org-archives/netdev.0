From: David Miller <davem@davemloft.net>
Subject: Re: net: convert remaining non-symbolic return values in
 ndo_start_xmit() functions
Date: Sun, 05 Jul 2009 19:47:55 -0700 (PDT)
Message-ID: <20090705.194755.05791300.davem@davemloft.net>
References: <4A40FF13.2060704@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36970
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753204AbZGFCrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2009 22:47:49 -0400
In-Reply-To: <4A40FF13.2060704@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 23 Jun 2009 18:13:07 +0200

>     net: convert remaining non-symbolic return values in ndo_start_xmit() functions
>     
>     This patch converts the remaining occurences of raw return values to their
>     symbolic counterparts in ndo_start_xmit() functions that were missed by the
>     previous automatic conversion.
>     
>     Additionally code that assumed the symbolic value of NETDEV_TX_OK to be zero
>     is changed to explicitly use NETDEV_TX_OK.
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied to net-next-2.6....

