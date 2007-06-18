From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] fix race in AF_UNIX
Date: Mon, 18 Jun 2007 12:47:21 +0100
Message-ID: <20070618124721.56411b93@the-village.bc.nu>
References: <E1I0BzQ-0006gZ-00@dorka.pomaz.szeredi.hu>
	<20070618.005711.21897961.davem@davemloft.net>
	<E1I0CTH-0006k3-00@dorka.pomaz.szeredi.hu>
	<20070618.021813.105401188.davem@davemloft.net>
	<E1I0DYW-0006uZ-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, akpm@linux-foundation.org,
	viro@ftp.linux.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Miklos Szeredi <miklos@szeredi.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:40746 "EHLO
	the-village.bc.nu" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754212AbXFRLm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 07:42:27 -0400
In-Reply-To: <E1I0DYW-0006uZ-00@dorka.pomaz.szeredi.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> No, correctness always trumps performance.  Lost packets on an AF_UNIX
> socket are _unexceptable_, and this is definitely not a theoretical
> problem.

If its so unacceptable why has nobody noticed until now - its a bug
clearly, it needs fixing clearly, but unless you can produce some kind of
exploit from it (eg a DoS attack or kernel memory leak exploiter) it
doesn't appear to be that serious.

> And BTW my second patch does _not_ have the performance problems you
> are arguing about, it's just plain ugly.  But hey, if you can't live
> with ugly code, go and fix it.

If you put ugly code into the kernel you pay for maintaining it for years
to come. If you get it right then you don't

> Do you want me to send the patch to Andrew instead?  His attitude
> towards bugfixes is rather better ;)

And it'll get NAKked and binned. DaveM is (as happens sometimes ;)) right
to insist on the code being clean and efficient.

Alan
