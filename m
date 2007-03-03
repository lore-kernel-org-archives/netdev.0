From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: avoid ptype_all packet handling
Date: Fri, 02 Mar 2007 20:22:11 -0800 (PST)
Message-ID: <20070302.202211.21926049.davem@davemloft.net>
References: <45E6802C.2090708@linux-foundation.org>
	<20070228.233034.74746721.davem@davemloft.net>
	<p733b4ncbui.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, greearb@candelatech.com,
	bridge@linux-foundation.org, netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33721
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2992943AbXCCEWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 23:22:14 -0500
In-Reply-To: <p733b4ncbui.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi@firstfloor.org>
Date: 03 Mar 2007 03:14:29 +0100

> That's pretty common with many x86 server boards because 
> they come with two NICs by default but must people only
> plug the cable into one. However the distro installers
> run DHCP on all.

Nope, that's not what I've seen them do, instead they run dhcp on
interfaces that report a link being present.
