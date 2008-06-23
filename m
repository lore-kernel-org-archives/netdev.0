From: Josip Rodin <joy@entuzijast.net>
Subject: Re: bnx2_poll panicking kernel
Date: Mon, 23 Jun 2008 23:36:57 +0200
Message-ID: <20080623213657.GA26447@orion.carnet.hr>
References: <20080621113406.5f89ae8d.billfink@mindspring.com> <C27F8246C663564A84BB7AB343977242019B6FEC8E@IRVEXCHCCR01.corp.ad.broadcom.com> <20080623180439.GA18829@orion.carnet.hr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Bill Fink' <billfink@mindspring.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	"mirrors@debian.org" <mirrors@debian.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orion.CARNet.hr ([161.53.160.90]:55420 "EHLO orion.carnet.hr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752948AbYFWVhD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2008 17:37:03 -0400
Content-Disposition: inline
In-Reply-To: <20080623180439.GA18829@orion.carnet.hr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 23, 2008 at 08:04:39PM +0200, Josip Rodin wrote:
> Oh, duh, yes, I'm a moron. It's back on now, sorry about that.

There we go, I got the debugging messages:

[...]
Jun 23 19:53:18 arrakis kernel: HTB: quantum of class 10100 is big. Consider r2q change.
Jun 23 22:57:55 arrakis kernel: bnx2: skb->nr_frags=1 is corrupted, should be 4
Jun 23 22:58:32 arrakis kernel: bnx2: skb->nr_frags=1 is corrupted, should be 2
Jun 23 22:59:02 arrakis kernel: bnx2: skb->nr_frags=1 is corrupted, should be 3
Jun 23 22:59:23 arrakis kernel: bnx2: skb->nr_frags=1 is corrupted, should be 9
Jun 23 22:59:36 arrakis kernel: bnx2: skb->nr_frags=1 is corrupted, should be 3
Jun 23 23:08:19 arrakis kernel: bnx2: skb->nr_frags=1 is corrupted, should be 3

-- 
     2. That which causes joy or happiness.
