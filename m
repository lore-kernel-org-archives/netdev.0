From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [PATCH RFC]: e1000: allow VLAN devices to use TSO and CSUM
	offload
Date: Fri, 10 Oct 2008 18:59:36 +0100
Message-ID: <1223661576.3984.114.camel@achroite>
References: <487DC7DB.70401@trash.net> <48EF690F.5070105@trash.net>
	 <36D9DB17C6DE9E40B059440DB8D95F520667243B@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:39615 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758412AbYJJR7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 13:59:44 -0400
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F520667243B@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-10-10 at 10:48 -0700, Brandeburg, Jesse wrote:
> Patrick McHardy wrote:
> > Patrick McHardy wrote:
> >> This patch changes e1000 to set vlan_features so TSO and CSUM
> >> offload can be used by VLAN devices, similar as with the other Intel
> >> drivers. 
> >> 
> >> Only RFC because I don't know whether there is buggy hardware
> >> that doesn't support this properly, but feel free to apply in
> >> case there isn't.
> > 
> > I never received a response to this. Any comments?
> 
> Sorry to delay the reply, the only one that stands out to me as a
> possible problem with the devices that e1000 still supports is the
> NETIF_F_TSO6.

vlan_features is a mask for features.  So long as all parts that do
support TSO-IPv6 also support it for VLAN-tagged packets, it should be
safe to set NETIF_F_TSO6 in vlan_features unconditionally.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

