From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH net] e100: Fix "disabling already-disabled device"
 warning
Date: Fri, 31 Jan 2014 00:40:16 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B7314C041@ORSMSX101.amr.corp.intel.com>
References: <1391079064-18411-1-git-send-email-michele@acksyn.org>
 <20140130.162745.1556632155972070897.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"idirectscm@aim.com" <idirectscm@aim.com>
To: David Miller <davem@davemloft.net>,
	"michele@acksyn.org" <michele@acksyn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:12770 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752809AbaAaAkS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 19:40:18 -0500
In-Reply-To: <20140130.162745.1556632155972070897.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of David Miller
> Sent: Thursday, January 30, 2014 4:28 PM
> To: michele@acksyn.org
> Cc: netdev@vger.kernel.org; e1000-devel@lists.sourceforge.net;
> idirectscm@aim.com
> Subject: Re: [PATCH net] e100: Fix "disabling already-disabled device"
> warning
> 
> From: Michele Baldessari <michele@acksyn.org>
> Date: Thu, 30 Jan 2014 10:51:04 +0000
> 
> > In https://bugzilla.redhat.com/show_bug.cgi?id=994438 and
> > https://bugzilla.redhat.com/show_bug.cgi?id=970480  we received
> > different reports of e100 throwing the following
> > warning:
>  ...
> > This patch removes pci_disable_device() from __e100_shutdown().
> > pci_clear_master() is enough.
> >
> > Signed-off-by: Michele Baldessari <michele@acksyn.org>
> > Tested-by: Mark Harig <idirectscm@aim.com>

Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>

Sorry if it's a duplicate, one I sent out earlier did not seem to hit netdev.


> 
> Can I get some Intel folks to review/ack this?
> 
> Thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the
> body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
