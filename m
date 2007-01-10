From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH/RFC 01/10] Implement local diversion of IPv4 skbs
Date: Wed, 10 Jan 2007 14:27:31 +0100
Message-ID: <200701101427.32243.netdev@axxeo.de>
References: <20070103163357.14635.37754.stgit@nienna.balabit> <1168421515.6746.14.camel@bzorp.balabit> <45A4DCD8.2080103@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Balazs Scheidler <bazsi@balabit.hu>, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org,
	KOVACS Krisztian <hidden@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:39051 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932383AbXAJN1l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jan 2007 08:27:41 -0500
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <45A4DCD8.2080103@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy schrieb:
> We support bitwise use of the mark everywhere in current kernels, so
> that shouldn't be a problem anymore.

For firewall mark based policy routing to work, one must still disable 
rp_filter, because this lookup doesn't take the mark into account[1].

So this statement is not quite true, although I believe you are probably right 
for this case.

BTW: This rp_filter=0 requirement isn't even officially documented 
	(e.g. in the LARTC).


Regards

Ingo Oeser

[1] But does take TOS into account for historic (???) reasons.
