From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: Netpoll client software?
Date: Tue, 14 Nov 2006 11:38:58 -0800
Message-ID: <F3EE2A9EB4576F40AFE238EC0AC04BC5099B8C7A@orsmsx402.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:33963 "EHLO mga03.intel.com")
	by vger.kernel.org with ESMTP id S966299AbWKNTjC convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Nov 2006 14:39:02 -0500
Content-class: urn:content-classes:message
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi folks, I'm looking for some suggestions for software that uses
the kernel's netpoll interface to receive packets.  The only in-kernel
application that uses netpoll right now is netconsole, and that only
sends packets.

Used to be, netdump would use the netpoll interface for both transmit
and receive, but netdump is gone now, and won't even compile on any
recent kernel.

I've made some changes to e1000's netpoll code to support some Top
Secret Upcoming Hardware, and I would like to be able to validate
my changes.

Any suggestions?

Thanks,
Mitch
