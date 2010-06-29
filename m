From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: IGB driver upgrade
Date: Mon, 28 Jun 2010 17:00:18 -0700
Message-ID: <4C293792.6070508@intel.com>
References: <AANLkTim6kfnr6yNeUXlLHOztB-qjyvj50D4p7nebqj9r@mail.gmail.com> <AANLkTinUoQG4BWC4Q2UFDwGvAwYujlUXz6P-ZLkZozaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: sbs <gexlie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:5401 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753620Ab0F2AAU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jun 2010 20:00:20 -0400
In-Reply-To: <AANLkTinUoQG4BWC4Q2UFDwGvAwYujlUXz6P-ZLkZozaQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sbs wrote:
> Hello guys.
> 
> Is it possible to upgrade intel gigabit adapter's e1000 driver to
> 2.2.9? This is the latest version according to Intel website.
> 
I assume you are referring to the igb driver since that is what is in 
the subject and not the e1000 driver correct?

> I've got a problem with 2.1.0-k2 drivers statically compiled into kernel.
> 
> Surely I can download drivers from intel and compile it as module, but
> I need to compile it statically
> Intel drivers do not provide sources for static compilation :(
> 
> Is it possible to upgrade drivers to igb-2.2.9 in the source tree and
> allow the static compilation of them?
> 
Normally the upstream driver should be up to date with any fixes that 
are in the standalone module.  What version of the kernel are you 
currently running?  Also have your tried testing the older standalone 
igb modules to see if the same issues exist there in either igb 2.1.9 or 
  igb 2.0.6?  This would help us to determine what changes in the 
standalone module might be missing from the in-kernel version of the driver.

> Because having 2.1.0-k2 we experience some strange random freezes with
> network interface which can be fixed only by restarting network.
> 
> 2.2.9 module has no such problems but we need to use static kernels
> according to our policy.

I have CCed our e1000-devel list.  In the future you may want to CC this 
list as it will provide better visibility to the Intel wired networking 
maintainers.

Thanks,

Alex
