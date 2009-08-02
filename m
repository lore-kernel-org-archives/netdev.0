From: David Miller <davem@davemloft.net>
Subject: Re: [Resent][PATCH 1/1] inet6: functions shadow global variable
Date: Sun, 02 Aug 2009 12:56:17 -0700 (PDT)
Message-ID: <20090802.125617.08000271.davem@davemloft.net>
References: <1248028721-24244-2-git-send-email-gerrit@erg.abdn.ac.uk>
	<1248028721-24244-3-git-send-email-gerrit@erg.abdn.ac.uk>
	<20090728194807.GB6277@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59209
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752833AbZHBT4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2009 15:56:09 -0400
In-Reply-To: <20090728194807.GB6277@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 28 Jul 2009 21:48:07 +0200

> inet6: local functions shadow global pointer
> 
> This renames away a variable clash:
>  * ipv6_table[] is declared as a static global table;
>  * ipv6_sysctl_net_init() uses ipv6_table to refer/destroy dynamic memory;
>  * ipv6_sysctl_net_exit() also uses ipv6_table for the same purpose;
>  * both the two last functions call kfree() on ipv6_table.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Applied.
