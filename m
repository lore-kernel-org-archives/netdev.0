From: David Miller <davem@davemloft.net>
Subject: Those gpio-mdio patches...
Date: Fri, 13 Nov 2009 13:59:08 -0800 (PST)
Message-ID: <20091113.135908.249908732.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lsorense@csclub.uwaterloo.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35986
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755320AbZKMV6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 16:58:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please don't fix the issue that way.  If the routine is returning a
true or false value, make it return a 'bool' instead of an 'int'.
That way we don't have to "accept something other than 0 and 1"

Thanks.
