From: James Morris <jmorris@namei.org>
Subject: Re: Is TCP over IPsec broken in 2.6.18?
Date: Sat, 30 Sep 2006 10:44:31 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609301044090.26813@d.namei>
References: <Pine.LNX.4.64.0609241029410.14827@d.namei>
 <E1GRdnS-0003kd-00@gondolin.me.apana.org.au> <20060925103836.GA13966@2ka.mipt.ru>
 <20060925112754.GA18228@gondor.apana.org.au> <20060925120519.GA19010@2ka.mipt.ru>
 <Pine.LNX.4.64.0609300037460.12011@d.namei> <Pine.LNX.4.64.0609300110190.12422@d.namei>
 <20060930111521.GA646@2ka.mipt.ru> <Pine.LNX.4.64.0609301035020.26766@d.namei>
 <20060930144018.GA16918@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.sea5.speakeasy.net ([69.17.117.8]:63623 "EHLO
	mail6.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751034AbWI3Ood (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Sep 2006 10:44:33 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060930144018.GA16918@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 30 Sep 2006, Evgeniy Polyakov wrote:

> On Sat, Sep 30, 2006 at 10:36:29AM -0400, James Morris (jmorris@namei.org) wrote:
> > On Sat, 30 Sep 2006, Evgeniy Polyakov wrote:
> > 
> > > I need to cofirm that broken system in my setup does have selinux enabled 
> > > with enforcing mode.
> > > I've changed it to permissive mode and it fixed setup (I do not see any 
> > > warnings in dmesg).
> > 
> > Something better in your case would likely be to rebuild the kernel with 
> > CONFIG_SECURITY_NETWORK_XFRM=n until it's fixed.
> 
> Well, it is acrypto test machine and I do not care about security there,
> so I can even disable selinux completely, but it will not help to resolve
> the issue, right?

Yes, it is a workaround.

> 
> So if you have some patches I'm more than happy to test them.

Ok, coming soon.


-- 
James Morris
<jmorris@namei.org>
