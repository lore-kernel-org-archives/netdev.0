From: David Miller <davem@davemloft.net>
Subject: Re: bug fix patch lost: git problem or just incorrect merge?
Date: Fri, 21 May 2010 15:02:53 -0700 (PDT)
Message-ID: <20100521.150253.149682718.davem@davemloft.net>
References: <1274456515.9022.14.camel@mulgrave.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-scsi@vger.kernel.org
To: James.Bottomley@suse.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1274456515.9022.14.camel@mulgrave.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Bottomley <James.Bottomley@suse.de>
Date: Fri, 21 May 2010 10:41:55 -0500

> Is this a git problem ... or is it just a mismerge in the net tree?

Mismerge, because sk->sk_sleep() doesn't exist any more I mistakenly
updated the original line to do the sk_sleep() stuff.

Sorry about that.
