From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [PATCH v2] net: don't allow CAP_NET_ADMIN to load non-netdev
 kernel modules
Date: Thu, 10 Mar 2011 01:06:34 +0300
Message-ID: <20110309220633.GA14750@albatros>
References: <1299010390.2529.30.camel@bwh-desktop>
 <20110301213313.GA6507@albatros>
 <4D6DEE7C.6020700@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, arnd@arndb.de, mirqus@gmail.com,
	netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, eric.dumazet@gmail.com, therbert@google.com,
	xiaosuo@gmail.com, jesse@nicira.com, kees.cook@canonical.com,
	eugene@redhat.com, dan.j.rosenberg@gmail.com
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:33733 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751514Ab1CIWGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 17:06:42 -0500
Content-Disposition: inline
In-Reply-To: <4D6DEE7C.6020700@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 02, 2011 at 10:15 +0300, Michael Tokarev wrote:
> 02.03.2011 00:33, Vasiliy Kulikov wrote:
> > Since a8f80e8ff94ecba629542d9b4b5f5a8ee3eb565c any process with
> > CAP_NET_ADMIN may load any module from /lib/modules/.  This doesn't mean
> > that CAP_NET_ADMIN is a superset of CAP_SYS_MODULE as modules are
> > limited to /lib/modules/**.  However, CAP_NET_ADMIN capability shouldn't
> > allow anybody load any module not related to networking.
> > 
> > This patch restricts an ability of autoloading modules to netdev modules
> > with explicit aliases.  This fixes CVE-2011-1019.
> []
> > Reference: https://lkml.org/lkml/2011/2/24/203
> > 
> > Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
> 
> This looks much saner :)
> 
> Signed-off-by: Michael Tokarev <mjt@tls.msk.ru>

Is there any reason why it is not yet merged?  I've answered to Jake
Edge that it is not a regression.

Thanks,

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments
