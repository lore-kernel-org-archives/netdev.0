From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 3/4] 8139too: RTNL and flush_scheduled_work deadlock
Date: Sat, 17 Feb 2007 21:54:01 +0100
Message-ID: <20070217205401.GA17396@electric-eye.fr.zoreil.com>
References: <20070215223744.GC19840@electric-eye.fr.zoreil.com> <20070216075936.GB1599@ff.dom.local> <20070216202034.GA10353@electric-eye.fr.zoreil.com> <20070216123605.56e697ac@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@o2.pl>, jeff@garzik.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	Ben Greear <greearb@candelatech.com>,
	Kyle Lucke <klucke@us.ibm.com>,
	Raghavendra Koushik <raghavendra.koushik@neterion.com>,
	Al Viro <viro@ftp.linux.org.uk>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:57474 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932890AbXBQU7h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Feb 2007 15:59:37 -0500
Content-Disposition: inline
In-Reply-To: <20070216123605.56e697ac@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@linux-foundation.org> :
[...]
> You need to hold a dev reference (dev_hold) as well. to keep the device
> from disappearing. or do a flush_scheduled_work in the remove routine.

The patched drivers do #2 (before unregister_netdev).

-- 
Ueimor
