From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] Fix kernel unaligned access with r8169 on sparc64
Date: Tue, 10 Jul 2007 22:59:10 +0200
Message-ID: <20070710205910.GA3436@electric-eye.fr.zoreil.com>
References: <200707061502.49146.florian.fainelli@telecomint.eu> <4692E347.3060200@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <florian.fainelli@telecomint.eu>,
	netdev@vger.kernel.org
To: Philip Craig <philipc@snapgear.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:45540 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757448AbXGJVA6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 17:00:58 -0400
Content-Disposition: inline
In-Reply-To: <4692E347.3060200@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Philip Craig <philipc@snapgear.com> :
[...]
> Try the patches at http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.22-rc6/
> I think patches 0012 and/or 0017 will fix this.

They should but they will not apply directly against 2.6.18-something.

Florian, can you consider one of the option below:
- try current 2.6.23-git. It contains the changes which should fix your
  alignment issues.
- try http://www.fr.zoreil.com/people/francois/backport/r8169/20070604-00
  It is a backport against 2.6.18 which should bring you quite close to
  2.6.23-git wrt r8169. 
  
-- 
Ueimor
