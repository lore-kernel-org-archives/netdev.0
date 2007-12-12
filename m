From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 8/8] [PATCH v2] [CCID3]: Interface CCID3 code with newer Loss Intervals Database
Date: Wed, 12 Dec 2007 17:21:44 +0000
Message-ID: <20071212172144.GA3560@gerrit.erg.abdn.ac.uk>
References: <1197108388630-git-send-email-gerrit@erg.abdn.ac.uk> <11971083883727-git-send-email-gerrit@erg.abdn.ac.uk> <11971083882049-git-send-email-gerrit@erg.abdn.ac.uk> <11971083881748-git-send-email-gerrit@erg.abdn.ac.uk> <11971083882534-git-send-email-gerrit@erg.abdn.ac.uk> <20071210210416.GB24046@ghostprotocols.net> <20071211094238.GA9926@gerrit.erg.abdn.ac.uk> <20071211172244.GF24046@ghostprotocols.net> <20071212165632.GB2282@gerrit.erg.abdn.ac.uk> <20071212170523.GT24046@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Arnaldo Carvalho de Melo <acme@redhat.com>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:63723 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751160AbXLLRWe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2007 12:22:34 -0500
Content-Disposition: inline
In-Reply-To: <20071212170523.GT24046@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > +static struct kmem_cache  *tfrc_lh_slab  __read_mostly;	/* <=== */
| 
| Yup, this one, is introduced as above but is not initialized at the
| module init routine, please see, it should be OK and we can move on:
| 
| http://git.kernel.org/?p=linux/kernel/git/acme/net-2.6.25.git;a=commitdiff;h=a925429ce2189b548dc19037d3ebd4ff35ae4af7
| 
Sorry for the confusion - you were right, the initialisation was sitting
in the wrong patch, not the one in the subject line. In your online
version the problem is fixed. Thanks a lot for all the work and for the
clarification.

Gerrit
