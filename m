From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 4/4] dccp: Resolve dependencies of features on choice
	of CCID
Date: Wed, 12 Nov 2008 07:14:03 +0100
Message-ID: <20081112061402.GA6405@gerrit.erg.abdn.ac.uk>
References: <1225950014-6337-4-git-send-email-gerrit@erg.abdn.ac.uk> <1225950014-6337-5-git-send-email-gerrit@erg.abdn.ac.uk> <20081110.131748.152587229.davem@davemloft.net> <20081110.132038.16329379.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:52775 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750956AbYKLGOM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2008 01:14:12 -0500
Content-Disposition: inline
In-Reply-To: <20081110.132038.16329379.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, -
| Send me something which actually compiles next time:
| 
| net/dccp/feat.c: In function ???__feat_register_nn???:
| net/dccp/feat.c:252: error: implicit declaration of function ???dccp_feat_default_value???
| net/dccp/feat.c:255: error: implicit declaration of function ???dccp_feat_push_change???
| make[2]: *** [net/dccp/feat.o] Error 1
| make[2]: *** Waiting for unfinished jobs....
| 
Apologies. This was a resubmitted set and patch 2/4, after diff-ing each
of the patches, was found to still have the old format. The set had been
changed to avoid build warnings about dependencies throughout, this
patch unfortunately had the old format.

When resubmitting next I will make sure to only use fresh copies for
each, no matter if it is the same patch. 

Will re-send the 4 from the up-to-date local copies, these are known to
compile without errors/warnings. 
