From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] Allow building iwl3945 without iwl4965.
Date: Tue, 29 Apr 2008 09:27:20 -0400
Message-ID: <20080429132720.GB4887@tuxdriver.com>
References: <87zlrgl09s.fsf@sparse.dyndns.org> <1209435597.2624.35.camel@debian.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Riedy <jason@acm.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3882 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754672AbYD2N66 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 09:58:58 -0400
Content-Disposition: inline
In-Reply-To: <1209435597.2624.35.camel@debian.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 29, 2008 at 10:19:57AM +0800, Zhu Yi wrote:

> Do we have a way to make "select IWLWIFI" generate CONFIG_IWLWIFI with
> the same state as CONFIG_IWLCORE (or CONFIG_IWL3945)? AFAICS,
> CONFIG_IWLWIFI is always 'y' whenever CONFIG_IWLCORE is 'y' or 'm'. If
> the latter is 'm', the Makefile will generate a empty built-in.o which
> requires vmlinux to update unnecessarily every time we only compile
> iwl3945/4965 modules.

Can you do something like  "default IWLCORE'?  Untested, off the top
of my head...

John
-- 
John W. Linville
linville@tuxdriver.com
