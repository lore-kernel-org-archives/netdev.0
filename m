From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Fwd: r8169 driver supporting the 8167 dev ID
Date: Wed, 11 Jul 2007 21:28:50 +0200
Message-ID: <20070711192850.GA4904@electric-eye.fr.zoreil.com>
References: <71421f560707091922y60dec801w836e1e4e88c36de2@mail.gmail.com> <71421f560707091923y64565c84wecb1229c219642c4@mail.gmail.com> <20070710212513.GB3436@electric-eye.fr.zoreil.com> <71421f560707101724x42fb6c8ye82bd08a9c7bca5@mail.gmail.com> <71421f560707110605x1bf79d7dj73ce7edd590b58ce@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jonathan Larsen <agentc0re@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:41177 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933631AbXGKT24 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2007 15:28:56 -0400
Content-Disposition: inline
In-Reply-To: <71421f560707110605x1bf79d7dj73ce7edd590b58ce@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jonathan Larsen <agentc0re@gmail.com> :
> I got git installed on my dev box.  i went to my linux source dir and ran,
> git init
> git add .
> git format-patch v2.6.18..v2.6.23-rc1 -- drivers/net/r8169.c
> 
> and i got an error
> fatal: bad revision 'v2.6.18..v2.6.23-rc1'
> 
> what did i do wrong?  im sure im missing something easy.

You should read the tutorial until you find the 'Using git for collaboration'
part. You missed a:

git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git

v2.6.23-rc1 is not available yet. Replace it with 'master' or, say,
4eb6bf6bfb580afaf1e1a1d30cba17a078530cf4

PS: please trim the irrelevant parts in your reply and do not top post. 

-- 
Ueimor
