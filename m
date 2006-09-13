From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: examples to model ethernet driver off of?
Date: Wed, 13 Sep 2006 23:05:56 +0200
Message-ID: <20060913210556.GI25007@electric-eye.fr.zoreil.com>
References: <9F51F56C-9924-4DEC-A823-892DDEE69131@kernel.crashing.org> <20060913195445.GH25007@electric-eye.fr.zoreil.com> <450865DB.4040809@intel.com> <7E7667E8-DD25-4F31-AE27-C7C2E92AC622@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Auke Kok <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:18130 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751199AbWIMVIy
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 17:08:54 -0400
To: Kumar Gala <galak@kernel.crashing.org>
Content-Disposition: inline
In-Reply-To: <7E7667E8-DD25-4F31-AE27-C7C2E92AC622@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kumar Gala <galak@kernel.crashing.org> :
[...]
> What is the feeling about e100.c?
> 
> I'm looking for something that is just basic tx/rx with no real fancy  
> features.

- a bit too much of 'if(' (missing space) and 'if (evil_statement'
- some 'return' which are not on a line of their own
- a few local variables could be added to avoid repeated foo->bar.baz[shnort]

But yes, it's quite nice.

-- 
Ueimor
