From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Is TCP over IPsec broken in 2.6.18?
Date: Sat, 30 Sep 2006 18:40:18 +0400
Message-ID: <20060930144018.GA16918@2ka.mipt.ru>
References: <Pine.LNX.4.64.0609241029410.14827@d.namei> <E1GRdnS-0003kd-00@gondolin.me.apana.org.au> <20060925103836.GA13966@2ka.mipt.ru> <20060925112754.GA18228@gondor.apana.org.au> <20060925120519.GA19010@2ka.mipt.ru> <Pine.LNX.4.64.0609300037460.12011@d.namei> <Pine.LNX.4.64.0609300110190.12422@d.namei> <20060930111521.GA646@2ka.mipt.ru> <Pine.LNX.4.64.0609301035020.26766@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:38098 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751014AbWI3Ok0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2006 10:40:26 -0400
To: James Morris <jmorris@namei.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0609301035020.26766@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 30, 2006 at 10:36:29AM -0400, James Morris (jmorris@namei.org) wrote:
> On Sat, 30 Sep 2006, Evgeniy Polyakov wrote:
> 
> > I need to cofirm that broken system in my setup does have selinux enabled 
> > with enforcing mode.
> > I've changed it to permissive mode and it fixed setup (I do not see any 
> > warnings in dmesg).
> 
> Something better in your case would likely be to rebuild the kernel with 
> CONFIG_SECURITY_NETWORK_XFRM=n until it's fixed.

Well, it is acrypto test machine and I do not care about security there,
so I can even disable selinux completely, but it will not help to resolve
the issue, right?

So if you have some patches I'm more than happy to test them.
 
> - James
> -- 
> James Morris
> <jmorris@namei.org>

-- 
	Evgeniy Polyakov
