From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/2] nfct-extensions/timeout: adjust for changed
 nfct_timeout_snprintf API
Date: Sat, 26 May 2012 22:21:05 +0200
Message-ID: <20120526202105.GB452@1984>
References: <20120526180654.GB31938@1984>
 <1338058955-5789-1-git-send-email-jengelh@inai.de>
 <1338058955-5789-2-git-send-email-jengelh@inai.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:38870 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754490Ab2EZUVM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 May 2012 16:21:12 -0400
Content-Disposition: inline
In-Reply-To: <1338058955-5789-2-git-send-email-jengelh@inai.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 26, 2012 at 09:02:34PM +0200, Jan Engelhardt wrote:
> Despite requiring libnetfilter_cttimeout >= 1.0.0, it did not
> use the new API.
> 
> nfct-extensions/timeout.c: In function 'nfct_timeout_cb':
> nfct-extensions/timeout.c:99:2: error: too few arguments to function
> 	'nfct_timeout_snprintf'
> In file included from nfct-extensions/timeout.c:26:0:
> /usr/include/libnetfilter_cttimeout-1.0.0/libnetfilter_cttimeout/
> 	libnetfilter_cttimeout.h:114:5: note: declared here
> 
> 114: int nfct_timeout_snprintf(char *buf, size_t size,
> 	const struct nfct_timeout *, unsigned int type, unsigned int flags);

We noticed at the same time.

It's fixed now, and conntrack-tools 1.2.1 is out. Thanks!
