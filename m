From: David Miller <davem@davemloft.net>
Subject: Re: [patch 4/6] qeth: do not spin for SETIP ip assist command
Date: Sun, 04 Jan 2009 17:37:00 -0800 (PST)
Message-ID: <20090104.173700.149427423.davem@davemloft.net>
References: <20090102150139.830998000@de.ibm.com>
	<20090102150255.266826000@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60033
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751105AbZAEBg5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2009 20:36:57 -0500
In-Reply-To: <20090102150255.266826000@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: frank.blaschka@de.ibm.com
Date: Fri, 02 Jan 2009 16:01:43 +0100

> The ip assist hw command for setting an IP address last unacceptable
> long so we can not spin while we waiting for the irq. Since we can
> ensure process context for all occurrences of this command we can use
> wait.
> 
> Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>

Applied.
