From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Subject: Re: [PATCH -mm] Fix dev_load() compilation again
Date: Fri, 05 Sep 2008 12:54:51 -0700
Message-ID: <48C18E8B.9050201@ct.jp.nec.com>
References: <20080904224004.d3dd3076.akpm@linux-foundation.org> <20080905193244.GD11569@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Stephen Rothwell <sfr@canb.auug.org.au>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:31892 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751098AbYIETyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 15:54:54 -0400
In-Reply-To: <20080905193244.GD11569@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan wrote:
> dev_load() doesn't exist if MODULES=n.

Hi,

in -next tree, this patch fixes the compilation error instead of
my patch. So, there is a conflict.

commit 9b90dc7bc3079376567fc501e2e84751fa4040fd
Author: Stephen Rothwell <sfr@canb.auug.org.au>
Date:   Wed Aug 27 14:45:37 2008 +1000

    rr: build fix for remove CONFIG_KMOD from net

    Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

thanks,
Hiroshi Shimamoto
