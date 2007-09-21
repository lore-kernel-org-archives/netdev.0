From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Please pull 'iwlwifi' branch of wireless-2.6
Date: Fri, 21 Sep 2007 09:05:00 +0100
Message-ID: <20070921080500.GA29050@infradead.org>
References: <20070918185040.GF4940@tuxdriver.com> <20070919101326.GA32432@infradead.org> <1190337630.5718.136.camel@debian.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	"John W. Linville" <linville@tuxdriver.com>, davem@davemloft.net,
	jeff@garzik.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:55180 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751129AbXIUIFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 04:05:30 -0400
Content-Disposition: inline
In-Reply-To: <1190337630.5718.136.camel@debian.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 21, 2007 at 09:20:30AM +0800, Zhu Yi wrote:
> > The depends on m for CONFIG_IWL4965 and CONFIG_IWL3945 needs to go,
> > we don't put drivers int that need to be modular. 
> 
> Since we splited the code base for 3945 and 4965 by a simple "fork" of
> file iwl-base.c, some non-static functions names remain the same. Make
> the two drivers build into vmlinux at the same time will cause conflict.
> So to make them depend on m is a current workaround for .24. We will
> abstract a common iwl-core.ko and make driver specific iwl3945.ko and
> iwl4965.ko depend on it in .25 time frame.

This kind of stuff is not what we want to leak into mainline.  If you're
too busy to do that 5 minute sed search and replace I'll do it for you.
