From: Kelvin Ku <kelvin@telemetry-investments.com>
Subject: Re: RX performance degradation with e1000e in Linux 2.6.31 / F12
Date: Wed, 10 Feb 2010 17:13:20 -0500
Message-ID: <20100210221320.GA7373@ti94.telemetry-investments.com>
References: <20100210182404.GB6160@ti94.telemetry-investments.com> <4B73016F.5050106@cchtml.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Community support for Fedora users <users@lists.fedoraproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1a.telemetry-investments.com ([64.20.161.180]:48684 "EHLO
	sv1.telemetry-investments.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756586Ab0BJWNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 17:13:21 -0500
Content-Disposition: inline
In-Reply-To: <4B73016F.5050106@cchtml.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 10, 2010 at 12:56:47PM -0600, Michael Cronenworth wrote:
> Kelvin Ku wrote:
> > After upgrading from Linux 2.6.30 (Fedora Core 11) to 2.6.31 (F12), I am
> > experiencing significant packet loss on an Intel 82574L NIC running on the
> > e1000e driver. I was not experiencing this with kernel 2.6.30. I notice 2.6.30
> > uses e1000e version 0.3.3.4-k4 whereas 2.6.31 uses version 1.0.2-k2.
> 
> And the driver version would be the significance. It appears there are 
> (very) serious issues with the e1000e driver and the 82574L chip. I'm 
> having to use 2.6.30 on a F12 server with an 82574L to have network 
> connectivity at all. The issue has been reported[1] and it is being 
> investigated. We had a hard time convincing Intel it wasn't a 
> motherboard manufacturer problem.
> 
> [1] 
> http://sourceforge.net/tracker/?func=detail&aid=2908463&group_id=42302&atid=447449
> -- 
> users mailing list
> users@lists.fedoraproject.org
> To unsubscribe or change subscription options:
> https://admin.fedoraproject.org/mailman/listinfo/users
> Guidelines: http://fedoraproject.org/wiki/Communicate/MailingListGuidelines
> 

Note that my RX performance issue arises with the latest Intel e1000e driver,
1.1.2-NAPI, and an older Intel driver, 0.5.18.3-NAPI, as well. I can't get an
even older version of the driver, 0.4.1.7, to compile on Linux 2.6.31, probably
because the kernel API has changed since that driver was released.

- Kelvin
