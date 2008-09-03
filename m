From: Christopher Li <chrisl@vmware.com>
Subject: Re: + e1000e-prevent-corruption-of-eeprom-nvm.patch added to -mm
	tree
Date: Tue, 2 Sep 2008 20:04:49 -0700
Message-ID: <20080903030448.GB26161@vmware.com>
References: <200809021919.m82JJweC008488@imap1.linux-foundation.org> <36D9DB17C6DE9E40B059440DB8D95F52060519D7@orsmsx418.amr.corp.intel.com> <1220398304.32688.163.camel@bodhitayantram.eng.vmware.com> <20080903004454.GV7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zach Amsden <zach@vmware.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"arvidjaar@mail.ru" <arvidjaar@mail.ru>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Pratap Subrahmanyam <pratap@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:56996 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751121AbYICDNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 23:13:40 -0400
Content-Disposition: inline
In-Reply-To: <20080903004454.GV7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 02, 2008 at 05:44:56PM -0700, Ben Hutchings wrote:
> 
> All ethtool commands are serialised by the RTNL as Jesse said above.
>
What Zach trying to say is that, ioctl is not the only way to
reach the eepro read/write code inside the kernel.

Chris
 
