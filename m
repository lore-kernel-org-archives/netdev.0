From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc911x: enforce read-after-write timing restriction
 on eeprom access
Date: Fri, 27 Mar 2009 00:49:45 -0700 (PDT)
Message-ID: <20090327.004945.161845859.davem@davemloft.net>
References: <1238087676-14194-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ian.saturley@smsc.com
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57573
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752944AbZC0Ht5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 03:49:57 -0400
In-Reply-To: <1238087676-14194-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Thu, 26 Mar 2009 17:14:36 +0000

> The LAN911x datasheet specifies a minimum delay of 45ns between a write
> of E2P_DATA and any read.  This patch adds a single dummy read of
> BYTE_TEST to enforce this timing constraint.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

Applied.
