From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH v2 0/3] Add device tree probe support for imx fec driver
Date: Wed, 6 Jul 2011 00:19:01 -0600
Message-ID: <20110706061901.GH9978@ponder.secretlab.ca>
References: <1309878839-25743-1-git-send-email-shawn.guo@linaro.org>
 <20110705.194854.1875695946300840388.davem@davemloft.net>
 <20110705.223045.738515407552627580.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shawn.guo@linaro.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org, patches@linaro.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:38965 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754393Ab1GFGTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 02:19:04 -0400
Received: by pzk9 with SMTP id 9so3070531pzk.19
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2011 23:19:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20110705.223045.738515407552627580.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 05, 2011 at 10:30:45PM -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Tue, 05 Jul 2011 19:48:54 -0700 (PDT)
> 
> > All applied to net-next-2.6, thanks.
> 
> Come on guys:
> 
> drivers/of/of_net.c: In function 'of_get_phy_mode':
> drivers/of/of_net.c:45: error: implicit declaration of function 'of_property_read_string'
> 
> This is completely rediculious.
> 
> Don't tell me that it's appropriate to merge something into
> my net tree when it uses interfaces that don't even exist
> in Linus's tree.

Sorry about that, I missed the reference to that function which is
currently in my devicetree/next branch.  I can either take the series
via devicetree/next, or I can provide you with a topic branch
containing the needed commit that you can merge.  Whichever you prefer.

g.

