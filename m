From: Johannes Thumshirn <jthumshirn@suse.de>
Subject: Re: [PATCH 1/3] cw1200: Don't leak memory if krealloc failes
Date: Fri, 30 Sep 2016 14:33:57 +0200
Message-ID: <20160930123357.iatuxcbki2r5dce3@linux-x5ow.site>
References: <1475237495-15030-1-git-send-email-jthumshirn@suse.de>
 <1475238579.17481.56.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Solomon Peachy <pizza@shaftnet.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:52706 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932224AbcI3MeA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Sep 2016 08:34:00 -0400
Content-Disposition: inline
In-Reply-To: <1475238579.17481.56.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 30, 2016 at 02:29:39PM +0200, Johannes Berg wrote:
> 
> > +	tmp = krealloc(buf->begin, size, GFP_KERNEL | GFP_DMA);
> > +	if (tmp) {
> > 
> I think that check is inverted?
> 
> johannes

Fu.. you're right, of cause it's !tmp.

I'll resend.

Thanks,
	Johannes

-- 
Johannes Thumshirn                                          Storage
jthumshirn@suse.de                                +49 911 74053 689
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nürnberg
GF: Felix Imendörffer, Jane Smithard, Graham Norton
HRB 21284 (AG Nürnberg)
Key fingerprint = EC38 9CAB C2C4 F25D 8600 D0D0 0393 969D 2D76 0850
