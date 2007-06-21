From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH v2.6.22-rc5] cxgb2: handle possible NULL pointer dereferencing
Date: Thu, 21 Jun 2007 14:04:00 +0200
Message-ID: <20070621120358.GK18863@kernel.dk>
References: <a901b49a0706210500g43a4c4a5y19c9ddbd83a50828@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trivial@kernel.org, jgarzik@pobox.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: pradeep singh <pradeep.rautela@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([80.160.20.94]:17198 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752901AbXFUMEv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jun 2007 08:04:51 -0400
Content-Disposition: inline
In-Reply-To: <a901b49a0706210500g43a4c4a5y19c9ddbd83a50828@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 21 2007, pradeep singh wrote:
> Hi,
> 
> Chelsio's in kernel 10G driver does not checks the return value from
> t1_get_board_info() in cxgb2.c.
> t1_get_board_info may return a NULL and we still go on to dereference
> it in the for loop without checking for the NULL.
> 
> This patch fixes this.

Patch looks odd - bi is dereferenced a number of times after that loop
anyway, so I don't see your patch fixing much.

-- 
Jens Axboe

