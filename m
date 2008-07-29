From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: Re: "MD5 Hash NOT expected but found" ..
Date: Tue, 29 Jul 2008 19:40:08 +0300
Message-ID: <20080729164008.GR3820@mea-ext.zmailer.org>
References: <20080729160430.GQ3820@mea-ext.zmailer.org> <20080729091615.11595272@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from z2.cat.iki.fi ([212.16.98.133]:53770 "EHLO z2.cat.iki.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751435AbYG2QkM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2008 12:40:12 -0400
Received: (mea@mea-ext) by mail.zmailer.org id S3541780AbYG2QkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 19:40:08 +0300
Content-Disposition: inline
In-Reply-To: <20080729091615.11595272@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 29, 2008 at 09:16:15AM -0700, Stephen Hemminger wrote:
> On Tue, 29 Jul 2008 19:04:30 +0300
> Matti Aarnio <matti.aarnio@zmailer.org> wrote:
> 
> > Dmesg reports following on  2.6.26-0.45.rc4.git2.fc10.x86_64
> > 
> > MD5 Hash NOT expected but found (207.118.50.124, 4463)->(212.16.98.133, 25)
> > MD5 Hash NOT expected but found (207.118.50.124, 4463)->(212.16.98.133, 25)
> > MD5 Hash NOT expected but found (64.91.108.168, 3704)->(212.16.98.133, 25)
> > MD5 Hash NOT expected but found (64.91.108.168, 3704)->(212.16.98.133, 25)
...
> 
> Somebody is trying to connect with MD5 option.
> This kernel message is too verbose for production systems.

Probably yes.  I have seen those kernel messages less frequently than
once per day on average.   "Rule of Least Confusion" does suggest that
unless this really reports about something being wrong, it should not
report it  --  if it is generated because the coder was unsure of what
will happen, then the kernel needs more pacthing.

Current server uptime is 54 days, which means the kernel may have
already been patched somehow regarding this.

/Matti Aarnio
