From: David Howells <dhowells@redhat.com>
Subject: Re: [-mm patch] fix fs/nfs/nfsroot.c compile error
Date: Mon, 07 May 2007 11:47:51 +0100
Message-ID: <15958.1178534871@redhat.com>
References: <20070505164422.GD8975@stusta.de>  <20070505014955.8f3990b5.akpm@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	trond.myklebust@fys.uio.no, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57149 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932263AbXEGKuN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2007 06:50:13 -0400
In-Reply-To: <20070505164422.GD8975@stusta.de> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk <bunk@stusta.de> wrote:

> match_table_t was made "const" and gcc doesn't like "const __initdata":

Hmmm...  My gcc seems quite happy with it.  What gcc are you using?

Shouldn't __initdata override const?

> BTW: Why is this change to include/linux/parser.h in the net tree?

Because DaveM picked it up as part of my AFS patches, I guess.

David
