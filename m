From: Phil Oester <kernel@linuxace.com>
Subject: Re: [PATCH][BONDING] Add max_bonds kernel parameter
Date: Fri, 29 Feb 2008 11:31:59 -0800
Message-ID: <20080229193159.GA31576@linuxace.com>
References: <20080229185130.GA28138@linuxace.com> <4405.1204311836@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from adsl-67-120-171-161.dsl.lsan03.pacbell.net ([67.120.171.161]:42487
	"HELO linuxace.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753761AbYB2TcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 14:32:00 -0500
Content-Disposition: inline
In-Reply-To: <4405.1204311836@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 29, 2008 at 11:03:56AM -0800, Jay Vosburgh wrote:
> 	The kernel should already handle options for compiled-in
> modules.  For bonding, you'd put something like "bonding.max_bonds=3" on
> the kernel boot line.  No need to patch bonding for this.  This is
> described in Documentation/kernel-parameters.txt (right at the top).

Duh...guess I should've read the file I was patching. :-/
 
> 	On your other patch, I don't see a big issue with allowing
> max_bonds to be zero; I'll have a look at the details and test it out.

Thanks.  Initscripts doesn't like it when it is set to zero,
but at least we can hopefully get the kernel to allow it, then 
fixup initscipts later.

Phil
