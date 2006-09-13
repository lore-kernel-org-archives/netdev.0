From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: examples to model ethernet driver off of?
Date: Wed, 13 Sep 2006 22:55:23 +0200
Message-ID: <20060913205523.GE24477@electric-eye.fr.zoreil.com>
References: <9F51F56C-9924-4DEC-A823-892DDEE69131@kernel.crashing.org> <20060913195445.GH25007@electric-eye.fr.zoreil.com> <450865DB.4040809@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kumar Gala <galak@kernel.crashing.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:33707 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751185AbWIMU5B
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 16:57:01 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
Content-Disposition: inline
In-Reply-To: <450865DB.4040809@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok <auke-jan.h.kok@intel.com> :
[...]
> >tg3/bnx2/sky2/b44/8139cp
> 
> Can I add e1000/ixgb to that? ;)

Assume I have not noticed the smiley...

- $ grep int32 drivers/net/e1000/*
- $ grep ' if(' drivers/net/e1000/*
- tabs and spaces damage
- forward declarations (are not a substitute for documentation)
- static some_return_type
  e1000_shnortz(...

  I still use dumb grep

- wild return -EIO; in the middle of e1000_probe
- useless cast in e1000_probe::INIT_WORK() due to wrong prototype
  of e1000_reset_task().

It looks nicer than last time I poke my nose into it but I am not
completely sure that I would recommend it to a newcomer as the
climax of best practices or simplicity. Btw I do not remember if
it handles multi-page skb like everybody else either.

-- 
Ueimor
