From: David Miller <davem@davemloft.net>
Subject: Re: [REGRESSION] 2.6.24-rc7: e1000: Detected Tx Unit Hang
Date: Wed, 16 Jan 2008 23:20:37 -0800 (PST)
Message-ID: <20080116.232037.261622584.davem@davemloft.net>
References: <36D9DB17C6DE9E40B059440DB8D95F52042FA541@orsmsx418.amr.corp.intel.com>
	<20080115.210214.170759690.davem@davemloft.net>
	<36D9DB17C6DE9E40B059440DB8D95F520432DA91@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: slavon@bigtelecom.ru, elendil@planet.nl, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45086
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751721AbYAQHUm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 02:20:42 -0500
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F520432DA91@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Date: Wed, 16 Jan 2008 23:09:47 -0800

> We spent Wednesday trying to reproduce (without the patch) these issues
> without much luck, and have applied the patch cleanly and will continue
> testing it.  Given the simplicity of the changes, and the community
> testing, I'll give my ack and we will continue testing.

You need a slow CPU, and you need to make sure you do actually
trigger the TX limiting code there.

I bet your cpus are fast enough that it simply never triggers.
:-)

> Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>

Thanks for reviewing Jesse.
