From: James Morris <jmorris@namei.org>
Subject: Re: Is TCP over IPsec broken in 2.6.18?
Date: Sat, 30 Sep 2006 01:14:27 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609300110190.12422@d.namei>
References: <Pine.LNX.4.64.0609241029410.14827@d.namei>
 <E1GRdnS-0003kd-00@gondolin.me.apana.org.au> <20060925103836.GA13966@2ka.mipt.ru>
 <20060925112754.GA18228@gondor.apana.org.au> <20060925120519.GA19010@2ka.mipt.ru>
 <Pine.LNX.4.64.0609300037460.12011@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:44778 "EHLO
	mail8.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1750923AbWI3FO3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Sep 2006 01:14:29 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <Pine.LNX.4.64.0609300037460.12011@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 30 Sep 2006, James Morris wrote:

> I've just seen something similar and can recreate it with static keying 
> via setkey.

It's SELinux related.  Things work when the one system in this setup with 
SELinux enabled is changed to permissive mode.

No audit messages or AVCs, and it's not the /selinux/compat_net setting.


- James
-- 
James Morris
<jmorris@namei.org>
