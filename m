From: Matt Domsch <Matt_Domsch@Dell.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Fri, 6 Nov 2009 16:06:37 -0600
Message-ID: <20091106220637.GB15533@mock.linuxdev.us.dell.com>
References: <20091013173638.GE1119@ldl.fc.hp.com> <20091016003245.GD29672@ldl.fc.hp.com> <EDA0A4495861324DA2618B4C45DCB3EE589579@blrx3m08.blr.amer.dell.com> <20091016152053.GA9862@ldl.fc.hp.com> <1255707193.2869.12.camel@achroite> <20091016214024.GA10091@ldl.fc.hp.com> <EDA0A4495861324DA2618B4C45DCB3EE5895AF@blrx3m08.blr.amer.dell.com> <4ADC906E.2050909@kadzban.is-a-geek.net> <EDA0A4495861324DA2618B4C45DCB3EE5896D2@blrx3m08.blr.amer.dell.com> <20091106084921.GA16700@bongo.bofh.it>
Reply-To: Matt Domsch <Matt_Domsch@Dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Narendra_K@Dell.com, bryan@kadzban.is-a-geek.net, dannf@hp.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, Jordan_Hargrave@Dell.com,
	Charles_Ros
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxipps301.us.dell.com ([143.166.148.223]:7123 "EHLO
	ausxipps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760026AbZKFWGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 17:06:32 -0500
Content-Disposition: inline
In-Reply-To: <20091106084921.GA16700@bongo.bofh.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 06, 2009 at 09:49:21AM +0100, Marco d'Itri wrote:
> On Nov 04, Narendra_K@Dell.com wrote:
> 
> > SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*",
> > ATTR{smbios_name}=="Embedded_NIC_1", ATTR{type}=="1", KERNEL=="eth*",
> > NAME="eth0".
> As a distribution developer I highly value solutions like this which do
> not require patching every application which deals with interface names
> and then teaching users about aliases which only work in some places and
> are unknown to the kernel.

Fair enough - but would you object if we changed the naming scheme
from eth%d to something else?

-- 
Matt Domsch
Technology Strategist, Dell Office of the CTO
linux.dell.com & www.dell.com/linux
