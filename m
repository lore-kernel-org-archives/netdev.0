From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [net-next v3 1/8] i40e: main driver core
Date: Fri, 30 Aug 2013 11:10:29 -0700
Message-ID: <20130830111029.25d6d753@nehalam.linuxnetplumber.net>
References: <1377866347-23846-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1377866347-23846-2-git-send-email-jeffrey.t.kirsher@intel.com>
	<1377880368.2070.26.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Shannon Nelson <shannon.nelson@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:61176 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752709Ab3H3SKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 14:10:33 -0400
Received: by mail-pb0-f54.google.com with SMTP id ro12so2172953pbb.41
        for <netdev@vger.kernel.org>; Fri, 30 Aug 2013 11:10:33 -0700 (PDT)
In-Reply-To: <1377880368.2070.26.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 30 Aug 2013 09:32:48 -0700
Joe Perches <joe@perches.com> wrote:

> > +static int debug = -1;
> > +module_param(debug, int, 0);
> > +MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");  
> 
> Maybe make debug a bitfield instead?

No Joe, this is the standard mapping of debug to msglevel used
by most network devices. The debug parameter is converted
to mask by netif_msg_init.
