From: Olaf Hering <olaf@aepfle.de>
Subject: Re: [PATCH 6/7] hvsock: introduce Hyper-V VM Sockets feature
Date: Tue, 7 Jul 2015 12:10:25 +0200
Message-ID: <20150707101025.GA5003@aepfle.de>
References: <1436194049-27829-1-git-send-email-decui@microsoft.com>
 <1436261876.20057.132.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: gregkh@linuxfoundation.org, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org, apw@canonical.com,
	jasowang@redhat.com, kys@microsoft.com, haiyangz@microsoft.com
To: Dexuan Cui <decui@microsoft.com>, Paul Bolle <pebolle@tiscali.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.220]:36630 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755460AbbGGKKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 06:10:30 -0400
Content-Disposition: inline
In-Reply-To: <1436261876.20057.132.camel@tiscali.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 07, Paul Bolle wrote:

> On ma, 2015-07-06 at 07:47 -0700, Dexuan Cui wrote:
> > --- /dev/null
> > +++ b/net/hv_sock/Kconfig
> 
> > +config HYPERV_SOCK
> > +	tristate "Microsoft Hyper-V Socket (EXPERIMENTAL)"
> > +	depends on HYPERV
> > +	default m

> It's a bit odd to advise to say N if one is unsure and set the default
> to 'm' at the same time.

The 'default' line has to be removed IMO.

Olaf
