From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 27/27] HFI: hf ethtool support
Date: Wed, 02 Mar 2011 14:32:44 -0800 (PST)
Message-ID: <20110302.143244.102533245.davem@davemloft.net>
References: <1299100213-8770-27-git-send-email-dykmanj@linux.vnet.ibm.com>
	<1299102762.4277.4.camel@localhost>
	<4D6EC49A.9060405@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	piyushc@linux.vnet.ibm.com, fcchang@linux.vnet.ibm.com,
	wscadden@linux.vnet.ibm.com, winstonc@linux.vnet.ibm.com,
	sakolish@linux.vnet.ibm.com, jian@linux.vnet.ibm.com,
	clsoto@linux.vnet.ibm.com, sjsheppa@linux.vnet.ibm.com
To: dykmanj@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57029
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757973Ab1CBWcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 17:32:08 -0500
In-Reply-To: <4D6EC49A.9060405@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jim Dykman <dykmanj@linux.vnet.ibm.com>
Date: Wed, 02 Mar 2011 17:28:42 -0500

> It is 64-bit only, but we forgot to mention that in Kconfig.

Please do not mark this driver as 64-bit only in the Kconfig if
at all possible, as that will markedly decrease the build test
coverage of this driver.
