From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH] Allow building iwl3945 without iwl4965.
Date: Wed, 30 Apr 2008 10:14:39 +0800
Message-ID: <1209521679.2827.23.camel@debian.sh.intel.com>
References: <87zlrgl09s.fsf@sparse.dyndns.org>
	 <1209435597.2624.35.camel@debian.sh.intel.com>
	 <20080429132720.GB4887@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jason Riedy <jason@acm.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10138 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753454AbYD3CPi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 22:15:38 -0400
In-Reply-To: <20080429132720.GB4887@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-04-29 at 09:27 -0400, John W. Linville wrote:
> 
> > Do we have a way to make "select IWLWIFI" generate CONFIG_IWLWIFI
> with
> > the same state as CONFIG_IWLCORE (or CONFIG_IWL3945)? AFAICS,
> > CONFIG_IWLWIFI is always 'y' whenever CONFIG_IWLCORE is 'y' or 'm'.
> If
> > the latter is 'm', the Makefile will generate a empty built-in.o
> which
> > requires vmlinux to update unnecessarily every time we only compile
> > iwl3945/4965 modules.
> 
> Can you do something like  "default IWLCORE'?  Untested, off the top
> of my head...

I just realized the kernel now updates vmlinux when I type 'make' even
if nothing is changed in the source code. Is this a bug or feature?

Thanks,
-yi

