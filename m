From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] e1000: do not allow watchdog to reenable transmits on
 shutdown
Date: Fri, 07 Mar 2014 11:41:03 -0800
Message-ID: <1394221263.16156.77.camel@joe-AO722>
References: <20140307020420.GA10797@amt.cnet>
	 <1394162671.2214.36.camel@jtkirshe-mobl> <20140307151435.GB26026@amt.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Vladimir Davydov <VDavydov@parallels.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Marcelo Tosatti <mtosatti@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0007.hostedemail.com ([216.40.44.7]:33195 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752461AbaCGTlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 14:41:07 -0500
In-Reply-To: <20140307151435.GB26026@amt.cnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-03-07 at 12:14 -0300, Marcelo Tosatti wrote:
> On Thu, Mar 06, 2014 at 07:24:31PM -0800, Jeff Kirsher wrote:
> > On Thu, 2014-03-06 at 23:04 -0300, Marcelo Tosatti wrote:
> > > There is a race on the shutdown path of the e1000 driver
> > > that allows the card to DMA into free'd memory.
[]
> > Note- there are trailing whitespace issues and 2 comments are not
> > formatted correctly.  I can fix these up if there are no other issues
> > with the patch, if you want.
> 
> checkpatch.pl did not complain about those - feel free to fix them,
> thanks.

Maybe you need a newer version of checkpatch?

$ ./scripts/checkpatch.pl e1000-do-not-allow-watchdog-to-reenable-transmits-on-shutdown.patch 
ERROR: trailing whitespace
#63: FILE: drivers/net/ethernet/intel/e1000/e1000_main.c:528:
+^I/* do not allow watchdog to reenable transmits between $

ERROR: code indent should use tabs where possible
#64: FILE: drivers/net/ethernet/intel/e1000/e1000_main.c:529:
+           clearing E1000_TCTL_EN below and setting E1000_DOWN */$

WARNING: networking block comments start with * on subsequent lines
#64: FILE: drivers/net/ethernet/intel/e1000/e1000_main.c:529:
+	/* do not allow watchdog to reenable transmits between 
+           clearing E1000_TCTL_EN below and setting E1000_DOWN */

WARNING: networking block comments put the trailing */ on a separate line
#64: FILE: drivers/net/ethernet/intel/e1000/e1000_main.c:529:
+           clearing E1000_TCTL_EN below and setting E1000_DOWN */

total: 2 errors, 2 warnings, 44 lines checked

NOTE: whitespace errors detected, you may wish to use scripts/cleanpatch or
      scripts/cleanfile

e1000-do-not-allow-watchdog-to-reenable-transmits-on-shutdown.patch has style problems, please review.

If any of these errors are false positives, please report
them to the maintainer, see CHECKPATCH in MAINTAINERS.
