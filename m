From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: linux-next: Tree for September 3
Date: Thu, 4 Sep 2008 16:25:32 -0700 (PDT)
Message-ID: <alpine.LFD.1.10.0809041622510.3117@nehalem.linux-foundation.org>
References: <20080903191619.6b6b230e.sfr@canb.auug.org.au> <20080903214634.ea17ff53.akpm@linux-foundation.org> <alpine.LFD.1.10.0809032201510.3378@nehalem.linux-foundation.org> <20080903223318.84b6ce8b.akpm@linux-foundation.org>
 <alpine.LFD.1.10.0809040045190.3378@nehalem.linux-foundation.org> <20080904012544.cabed847.akpm@linux-foundation.org> <alpine.LFD.1.10.0809040143350.3452@nehalem.linux-foundation.org> <20080904015701.5959623a.akpm@linux-foundation.org>
 <alpine.LFD.1.10.0809040203510.3452@nehalem.linux-foundation.org> <20080904104554.32ffebea.akpm@linux-foundation.org> <alpine.LFD.1.10.0809041058140.3400@nehalem.linux-foundation.org> <20080904113408.d47c65f6.akpm@linux-foundation.org>
 <alpine.LFD.1.10.0809050041520.3243@apollo.tec.linutronix.de> <20080904161746.dc4800a4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Thomas Gleixner <tglx@linutronix.de>, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	yhlu.kernel@gmail.com, ink@jurassic.park.msu.ru,
	jbarnes@virtuousgeek.org, netdev@vger.kernel.org,
	viro@zeniv.linux.org.uk, ebiederm@xmission.com,
	dwmw2@infradead.org, sam@ravnborg.org, johnstul@us.ibm.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46785 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751005AbYIDX0C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 19:26:02 -0400
In-Reply-To: <20080904161746.dc4800a4.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 4 Sep 2008, Andrew Morton wrote:
> 
> erm, I might have lost that binary, and it only happened the once.  It
> happened shortly after the machine had fully booted, during
> establishment of the first sshd session.

Considering that both this and your odd /proc/net issue look like memory 
corruption, maybe CONFIG_DEBUG_SLAB and CONFIG_DEBUG_PAGEALLOC are worth 
testing?

		Linus
