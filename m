From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: RE: [PATCH] Ethtool: Beautify private flags print
Date: Fri, 24 May 2013 03:50:45 +0000
Message-ID: <979A8436335E3744ADCD3A9F2A2B68A52AC5EE34@SJEXCHMB10.corp.ad.broadcom.com>
References: <1369331751-32543-1-git-send-email-yuvalmin@broadcom.com>
 <1369333817.2075.34.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Joe Perches" <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3354 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759950Ab3EXDu4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 23:50:56 -0400
In-Reply-To: <1369333817.2075.34.camel@joe-AO722>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Thu, 2013-05-23 at 20:55 +0300, Yuval Mintz wrote:
> > When printing the private flags of the device, align all strings
> > to have the same length.
> []
> > diff --git a/ethtool.c b/ethtool.c
> []
> > +	for (i = 0; i < strings->len; i++) {
> > +		int j;
> > +
> > +		printf("%s", (const char *)strings->data +
> > +					   i * ETH_GSTRING_LEN);
> > +
> > +		cur_len = strlen((const char*)strings->data +
> > +					      i * ETH_GSTRING_LEN);
> > +		for (j = 0; j < max_len - cur_len; j++)
> > +			printf(" ");
> 
> I think this isn't necessary, but this is simpler
> 
> "%-*s", max_len, strings->data + i * ETH_GSTRING_LEN

Nice - I was unfamiliar with this second-order format string modifier.
I'll modify the patch into using this format.
