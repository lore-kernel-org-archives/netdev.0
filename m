From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net 1/2] ipv6: do not delete previously existing ECMP
 routes if add fails
Date: Wed, 13 May 2015 22:06:56 +0200
Message-ID: <20150513200656.GA31076@unicorn.suse.cz>
References: <cover.1431500953.git.mkubecek@suse.cz>
 <4e3d075f2be93d9655bc1372a107584368a29eab.1431500953.git.mkubecek@suse.cz>
 <55534389.8070307@6wind.com>
 <20150513124940.GB27366@unicorn.suse.cz>
 <555351EC.9050805@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:48064 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753207AbbEMUG6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2015 16:06:58 -0400
Content-Disposition: inline
In-Reply-To: <555351EC.9050805@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 13, 2015 at 06:30:20AM -0700, roopa wrote:
> >
> This looks like a similar bug i was trying to fix some time back:
> http://patchwork.ozlabs.org/patch/362296/
> 
> (I am not sure if my full patch is still valid. I was thinking of
> re-spining it sometime soon. If you are interested in trying it out,
> please do)

It's essentially the same idea but I prefer to use variable remaining
which is already there and is needed anyway rather than introduce
three extra variables for the cleanup (which is quite similar to the
suggestion from Hannes' reply).

I've sent v2 few minutes ago.

                                                       Michal Kubecek
