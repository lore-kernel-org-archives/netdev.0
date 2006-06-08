From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 6666] New: invalid tcp socket connection to
 windows stacks
Date: Thu, 08 Jun 2006 11:57:59 -0700 (PDT)
Message-ID: <20060608.115759.104039425.davem@davemloft.net>
References: <20060608103627.23cfc83a.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, technik@power-netz.de,
	bugme-daemon@bugzilla.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:21975
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964943AbWFHS6R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jun 2006 14:58:17 -0400
To: akpm@osdl.org
In-Reply-To: <20060608103627.23cfc83a.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


FIN only gets output when the connection is actually closed
for sending, and that is controlled by the application not
by the kernel.
