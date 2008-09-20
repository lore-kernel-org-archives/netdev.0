From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] gianfar: Free/iounmap memory after an error in mii bus
 initialization
Date: Fri, 19 Sep 2008 17:24:31 -0700
Message-ID: <20080919172431.7be41b16.akpm@linux-foundation.org>
References: <1221773874-3273-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, danielm77@spray.se,
	afleming@freescale.com
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57188 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752011AbYITAZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 20:25:17 -0400
In-Reply-To: <1221773874-3273-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Sep 2008 16:37:54 -0500
Andy Fleming <afleming@freescale.com> wrote:

> Recent changes to MII bus initialization code added exit points which
> didn't free or iounmap the bus before returning.
> 
> This was reported as bug #11372
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>

administrivia:

- Adding a

	Reported-by: Daniel Marjamki <danielm77@spray.se>

  would be nice.

- When referencing a bugzilla report in the changelog I like to use
  the full URL.  Because there are people who periodically troll the
  mainline commits closing off bugzilla reports.  Using the full
  URL minimises the chance that they will miss something.

