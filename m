From: "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>
Subject: Re: Netpoll client software?
Date: Tue, 14 Nov 2006 17:42:49 -0500
Message-ID: <20061114224249.GA30606@ti64.telemetry-investments.com>
References: <F3EE2A9EB4576F40AFE238EC0AC04BC5099B8C7A@orsmsx402.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1a.telemetry-investments.com ([64.20.161.180]:47821 "EHLO
	sv1.telemetry-investments.com") by vger.kernel.org with ESMTP
	id S966421AbWKNWmu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Nov 2006 17:42:50 -0500
To: "Williams, Mitch A" <mitch.a.williams@intel.com>
Content-Disposition: inline
In-Reply-To: <F3EE2A9EB4576F40AFE238EC0AC04BC5099B8C7A@orsmsx402.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 14, 2006 at 11:38:58AM -0800, Williams, Mitch A wrote:
> Hi folks, I'm looking for some suggestions for software that uses
> the kernel's netpoll interface to receive packets.  The only in-kernel
> application that uses netpoll right now is netconsole, and that only
> sends packets.
> 
> Used to be, netdump would use the netpoll interface for both transmit
> and receive, but netdump is gone now, and won't even compile on any
> recent kernel.
> 
> I've made some changes to e1000's netpoll code to support some Top
> Secret Upcoming Hardware, and I would like to be able to validate
> my changes.
> 
> Any suggestions?
 
kgdboe - kgdb over ethernet.

There are various patch versions floating around, one of which was in
Andrew Morton's -mm kernels.

Regards,

	Bill rugolsky
