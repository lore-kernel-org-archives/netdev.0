From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Is TCP over IPsec broken in 2.6.18?
Date: Sat, 30 Sep 2006 15:15:21 +0400
Message-ID: <20060930111521.GA646@2ka.mipt.ru>
References: <Pine.LNX.4.64.0609241029410.14827@d.namei> <E1GRdnS-0003kd-00@gondolin.me.apana.org.au> <20060925103836.GA13966@2ka.mipt.ru> <20060925112754.GA18228@gondor.apana.org.au> <20060925120519.GA19010@2ka.mipt.ru> <Pine.LNX.4.64.0609300037460.12011@d.namei> <Pine.LNX.4.64.0609300110190.12422@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:37553 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1750835AbWI3LP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2006 07:15:57 -0400
To: James Morris <jmorris@namei.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0609300110190.12422@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 30, 2006 at 01:14:27AM -0400, James Morris (jmorris@namei.org) wrote:
> On Sat, 30 Sep 2006, James Morris wrote:
> 
> > I've just seen something similar and can recreate it with static keying 
> > via setkey.
> 
> It's SELinux related.  Things work when the one system in this setup with 
> SELinux enabled is changed to permissive mode.
> 
> No audit messages or AVCs, and it's not the /selinux/compat_net setting.

I need to cofirm that broken system in my setup does have selinux enabled 
with enforcing mode.
I've changed it to permissive mode and it fixed setup (I do not see any 
warnings in dmesg).
 
> - James
> -- 
> James Morris
> <jmorris@namei.org>

-- 
	Evgeniy Polyakov
