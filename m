From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] file descriptor loss while receiving SCM_RIGHTS
Date: Mon, 09 Oct 2006 21:42:29 -0700 (PDT)
Message-ID: <20061009.214229.01913749.davem@davemloft.net>
References: <E1GWWHP-0006jw-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:30440
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964968AbWJJEma (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 00:42:30 -0400
To: miklos@szeredi.hu
In-Reply-To: <E1GWWHP-0006jw-00@dorka.pomaz.szeredi.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Miklos Szeredi <miklos@szeredi.hu>
Date: Sun, 08 Oct 2006 12:53:11 +0200

> If more than one file descriptor was sent with an SCM_RIGHTS message,
> and on the receiving end, after installing a nonzero (but not all)
> file descritpors the process runs out of fds, then the already
> installed fds will be lost (userspace will have no way of knowing
> about them).
> 
> The following patch makes sure, that at least the already installed
> fds are sent to userspace.  It doesn't solve the issue of losing file
> descriptors in case of an EFAULT on the userspace buffer.
> 
> Signed-off-by: Miklos Szeredi <miklos@szeredi.hu>

Looks good.  Applied, thanks Miklos.
