From: David Miller <davem@davemloft.net>
Subject: stmmac patches...
Date: Thu, 19 Nov 2009 12:18:21 -0800 (PST)
Message-ID: <20091119.121821.51205410.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59246
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752792AbZKSUSE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 15:18:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please do not intermix coding style changes with bug
fixes.

In your second patch you change the indentation of
the arguments to ->init_rx_desc() in stmmac_suspend()

Not only is this inappropriate in a bug fix patch, it
is actually making the indentation incorrect.  The
arguments should line up to the column after the
function argument set openning '(' on the previous
line.

Please fix this up and resubmit both of your patches.

Thank you.
