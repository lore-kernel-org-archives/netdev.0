From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [GIT/PATCH v4] xen network backend driver
Date: Thu, 10 Mar 2011 09:14:25 -0800
Message-ID: <20110310091425.3451f7f1@nehalam>
References: <1299776554.17339.824.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel <xen-devel@lists.xensource.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50140 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751606Ab1CJRO2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2011 12:14:28 -0500
In-Reply-To: <1299776554.17339.824.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Mar 2011 17:02:33 +0000
Ian Campbell <Ian.Campbell@citrix.com> wrote:

> +	/* Flags that must not be set in dev->features */
> +	int features_disabled;

dev->features is unsigned long, so this mask should be as well.

-- 
